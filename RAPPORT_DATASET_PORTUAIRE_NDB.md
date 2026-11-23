# Rapport — Jeu de données "gestion portuaire" pour tests de performance MySQL Cluster (NDB)

**Auteur :** agent explore  
**Date :** 22 novembre 2026  
**Cible :** 3 VM VirtualBox sur vboxnet0 192.168.56.0/24 — moteur NDB (in-memory)  
**Statut :** document de recherche / recommandation (hors cours chapitres 1-5)

---

## 1. Contexte infrastructure (pris en compte)

### 1.1 Architecture des 3 VM

| VM | Adresse IP | Rôle | NodeId(s) | Composants |
|----|-----------|------|-----------|------------|
| VM 1 | 192.168.56.10 | Gestion + SQL | 1 (mgmd), 4 (mysqld) | nœud de gestion + nœud SQL |
| VM 2 | 192.168.56.11 | Stockage | 2, 3 (ndbmtd) | 2 nœuds stockage, NoOfReplicas = 2 |
| VM 3 | 192.168.56.12 | SQL supplémentaire | 5 (mysqld) | 2e nœud SQL |

- Chaque VM : 1 vCPU, 1-2 Go RAM, 15 Go disque, Ubuntu Server 24.04 LTS
- Réseau isolé vboxnet0, DHCP désactivé, hôte 192.168.56.1
- Pas d'accès Internet pendant les labs
- Snapshots propres avant manipulation (sysadmin)

### 1.2 Configuration NDB actuelle (config.ini)

```ini
[ndb_mgmd default]
DataDir = /var/lib/mysql-cluster

[ndbd default]
NoOfReplicas = 2
DataMemory = 256M
IndexMemory = 128M

[tcp default]

[ndb_mgmd]
NodeId = 1
HostName = 192.168.56.10

[ndbd]
NodeId = 2
HostName = 192.168.56.11
DataDir = /var/lib/mysql-cluster/ndb_2

[ndbd]
NodeId = 3
HostName = 192.168.56.11
DataDir = /var/lib/mysql-cluster/ndb_3

[mysqld]
NodeId = 4
HostName = 192.168.56.10

[mysqld]
NodeId = 5
HostName = 192.168.56.12
```

**Contrainte clé :** les 2 nœuds de stockage (NodeId 2 et 3) sont tous les deux sur **VM 2** (192.168.56.11). VM 2 dispose de 1-2 Go RAM et doit faire tourner 2 processus ndbmtd en parallèle, chacun allouant DataMemory + IndexMemory. C'est le goulot de mémoire principal.

> Rappel : avec `NoOfReplicas = 2` et 2 nœuds de stockage, il y a **un seul node group** (2 réplicas). Chaque réplica stocke l'intégralité des données. La capacité utile du cluster = capacité d'UN node (pas la somme des 2).

---

## 2. Sources de schémas de données portuaires (recherche effectuée)

### 2.1 Modèles de données de référence (TOS / standards maritimes)

| Source | Type | Contenu | Licence | Lien |
|--------|------|---------|---------|------|
| smart-data-models / dataModel.MarineTransport | Modèle d'entités NGSI-LD (ETSI/CEN) | Berth, Operation, PortCall, PortCallEvent, Vessel, MasterVessel, AisVessel, Port, Terminal, Facility, Company, EdiCodeco (UN/EDIFACT CODECO), Booking, Bollard, NavigationSector, TrackedManeuver | Ouvert (GitHub) | https://github.com/smart-data-models/dataModel.MarineTransport |
| DataPorts Project / datamodel | Modèle commun JSON Schema (UE) | Cargo, Container, CargoManifest, Customs, Truck, Vehicle, TruckDriver, Vessel, Shipment, StoredItem, TrackableEntity/Event, TransportUnit, Geofencing, Posidonia | CC-BY-4.0 | https://github.com/DataPortsProject/datamodel |
| ERP•AI — Port & Terminal Management | Modèle opérationnel (14 tables) | Loads, Organizations, Team members, Transport partners, Load stops, Container moves, Record attachments, Review decisions, Operation receipts, Load assignments, Drivers, Vehicles, Stops/delivery evidence | Propriétaire (aperçu public) | https://www.erp.ai/port-terminal-management/data-model |
| RisingWave — Real-Time Port Operations Monitoring | Modèle événementiel (streams) | AIS vessel positions, Berth/equipment events (crane cycle, berth allocation), Gate transactions (truck IN/OUT), Cargo transfer events | Article technique | https://risingwave.com/blog/real-time-port-operations-monitoring-sql |
| VLDB 2025 Workshop (LSGDA) | Modèle relationnel SCM portuaire | Containers, carriers, modes, services, liners, flexible attributes, arrival/departure events, dwell times | Papier académique | https://www.vldb.org/2025/Workshops/VLDB-Workshops-2025/LSGDA/LSGDA25_09.pdf |
| PoC Performance Monitoring Container Terminals (MDPI) | Données réelles TOS/MIS | 56 198 183 enregistrements CODECO (gate-in/gate-out), dimensions quai, équipement, ship entry/exit, stockage | Recherche (MDPI) | https://www.mdpi.com/2077-1312/8/12/971 |

### 2.2 Datasets ouverts réutilisables (données de référence / seed)

| Source | Dataset | Taille | Contenu | Licence | Lien |
|--------|---------|--------|---------|---------|------|
| Kaggle (dsfoxx) | Largest Maritime Hubs — Container Ports | < 1K lignes | Top 50 ports mondiaux, TEU, UN/LOCODE, coords, pays | CC0 | https://www.kaggle.com/datasets/dsfoxx/worlds-largest-container-ports |
| Kaggle (sanjeetsinghnaik) | Shipping Ports Around The World | 44 Ko, 450+ ports | Nom, UN Code, pays, type, arrivées/départs 24h, navires | CC0 | https://www.kaggle.com/datasets/sanjeetsinghnaik/ship-ports |
| Kaggle (thomaszengerle) | Container Terminal Event Log — Dwelling Time | 56,8 Mo, ~760k événements | Event log terminal : BAPLIE, VESSEL_ATB, DISCHARGE, STACK, CUSTOMS_DEL, TRUCK_IN/OUT, QUARANTINE, JOB_DEL | CC BY 4.0 | https://www.kaggle.com/datasets/thomaszengerle/container-terminal-event-log-dwelling-time |
| Kaggle (bobaaayoung) | Container Ship Data Collection | 135,9 Mo, 17 colonnes | Navires, IMO, position, ports départ/arrivée, ETA/ETD/ATA/ATD | Apache 2.0 | https://www.kaggle.com/datasets/bobaaayoung/container-ship-data-collection |
| data.gouv.fr | Maritime : transport de marchandises | 266 Ko CSV | Trafic maritime annuel marchandises (tonnes + EVP) par type, autorités portuaires françaises | Licence Ouverte | https://www.data.gouv.fr/datasets/maritime-transport-de-marchandises |
| data.gouv.fr | Ports — Espace maritime français | Multiples fichiers | Référentiel ports maritimes/fluvio-maritimes (IFREMER, SHOM, SAR, SANDRE) | Licence Ouverte | https://www.data.gouv.fr/datasets/ports-espace-maritime-francais |
| data.gouv.fr | Informations portuaires (Shom, S-57) | 13 classes | BERTHS (poste d'amarrage), CRANES, HRBARE (zone portuaire), PILBOP, etc. | Licence Ouverte v2 | https://logistique.data.gouv.fr/datasets/658f61c5d5af8f06a6c71b48 |
| data.gouv.fr / Europe | Worldwide list of seaports (v2021) | 13 709 ports, 187 pays | Nom, UN/LOCODE, pays ISO3, coords WGS84, statut | Ouvert | https://data.europa.eu/data/datasets/... |
| Mendeley Data | Source du dataset dwelling time (sciencedirect) | — | Données événementielles terminal conteneurs | — | https://data.mendeley.com/datasets/yvp2b4rtp3/1 |

**Recommandation :** utiliser les référentiels ports (Kaggle dsfoxx / data.gouv seaports) pour les tables de référence (ports, quais), le dataset "Container Terminal Event Log" (Mendeley/Kaggle) comme modèle d'opérations réelles, et compléter par un générateur synthétique pour les volumes de test.


---

## 3. Schéma SQL proposé (adapté à NDB Cluster)

### 3.1 Principes de conception pour NDB

- **Chaque table NDB doit avoir une PRIMARY KEY.** Si absent, NDB en crée une automatique (non USING HASH).
- **PREFER `USING HASH` pour les PK et index uniques** : 21-25 octets/enregistrement (IndexMemory → DataMemory en NDB 8.0) contre 31-35 octets avec index ordonné. Mise à jour 20-30 % plus rapide.
- **Index ordonné (10 octets/enregistrement, DataMemory)** uniquement pour les colonnes recherchées par plages (dates, plages de TEU).
- **Éviter les colonnes TEXT/BLOB volumineuses** : les BLOB sont stockés dans des tables internes blob, chaque partie ajoute une opération à la transaction.
- **Types entiers compacts** : `INT UNSIGNED` (4 octets) pour les IDs, `SMALLINT`/`TINYINT` pour les codes, `DECIMAL(12,2)` pour les montants.
- **`TIMESTAMP`/`DATETIME`** pour les événements horodatés.
- **VARCHAR limité** (pas de TEXT) pour codes et libellés courts.
- **Pas de FOREIGN KEY** entre tables NDB (NDB ne supporte pas les FK inter-tables de manière performante ; les intégrités sont gérées applicativement).
- **Partitionnement implicite** par la PK (NDB partitionne automatiquement sur la PK). Choisir une PK à bonne cardinalité pour répartir sur les LDM threads.

### 3.2 Dictionnaire de données (14 tables)

#### 3.2.1 Référentiels (petites tables, lecture fréquente)

```sql
-- Ports (référentiel mondial, seed depuis data.gouv / Kaggle)
CREATE TABLE ports (
    port_id         INT UNSIGNED NOT NULL,
    unlocode        CHAR(5) NOT NULL,
    port_name       VARCHAR(100) NOT NULL,
    country         VARCHAR(60) NOT NULL,
    country_iso2    CHAR(2) NOT NULL,
    region          VARCHAR(40),
    latitude        DECIMAL(9,6),
    longitude       DECIMAL(9,6),
    teu_capacity    INT UNSIGNED,
    operator        VARCHAR(100),
    PRIMARY KEY (port_id) USING HASH
) ENGINE=NDB COMMENT='Referentiel des ports';

-- Quais / Berths (un port peut avoir plusieurs quais)
CREATE TABLE berths (
    berth_id        INT UNSIGNED NOT NULL,
    port_id         INT UNSIGNED NOT NULL,
    berth_code      VARCHAR(20) NOT NULL,
    berth_name      VARCHAR(80),
    max_loa_m       DECIMAL(6,2),
    max_draft_m     DECIMAL(5,2),
    quay_cranes     TINYINT UNSIGNED,
    terminal_id     INT UNSIGNED,
    PRIMARY KEY (berth_id) USING HASH,
    KEY idx_berth_port (port_id) USING HASH
) ENGINE=NDB COMMENT='Quais et postes d amarrage';

-- Terminaux
CREATE TABLE terminals (
    terminal_id     INT UNSIGNED NOT NULL,
    port_id         INT UNSIGNED NOT NULL,
    terminal_name   VARCHAR(80) NOT NULL,
    terminal_type   VARCHAR(30),
    PRIMARY KEY (terminal_id) USING HASH,
    KEY idx_terminal_port (port_id) USING HASH
) ENGINE=NDB COMMENT='Terminaux portuaires';

-- Navires (referentiel, seed depuis AIS / port authorities)
CREATE TABLE vessels (
    vessel_id       INT UNSIGNED NOT NULL,
    imo             VARCHAR(10) NOT NULL,
    vessel_name     VARCHAR(100) NOT NULL,
    vessel_type     VARCHAR(30),
    gross_tonnage   INT UNSIGNED,
    loa_m           DECIMAL(7,2),
    beam_m          DECIMAL(6,2),
    flag_country    CHAR(2),
    owner_company   VARCHAR(100),
    PRIMARY KEY (vessel_id) USING HASH,
    KEY idx_vessel_imo (imo) USING HASH
) ENGINE=NDB COMMENT='Referentiel des navires';

-- Compagnies / armateurs
CREATE TABLE companies (
    company_id      INT UNSIGNED NOT NULL,
    company_name    VARCHAR(100) NOT NULL,
    country         CHAR(2),
    PRIMARY KEY (company_id) USING HASH
) ENGINE=NDB COMMENT='Compagnies maritimes et armateurs';

-- Vehicules terrestres (porteurs, camions)
CREATE TABLE vehicles (
    vehicle_id      INT UNSIGNED NOT NULL,
    license_plate   VARCHAR(15) NOT NULL,
    vehicle_type    VARCHAR(20),
    capacity_teu    TINYINT UNSIGNED,
    company_id      INT UNSIGNED,
    PRIMARY KEY (vehicle_id) USING HASH,
    KEY idx_vehicle_plate (license_plate) USING HASH
) ENGINE=NDB COMMENT='Vehicules de transport terrestre';

-- Conteneurs (referentiel des conteneurs actifs)
CREATE TABLE containers (
    container_no    VARCHAR(11) NOT NULL,
    owner_code      VARCHAR(4),
    size_type       VARCHAR(4),
    length_ft       TINYINT UNSIGNED,
    height_ft       TINYINT UNSIGNED,
    status          VARCHAR(20),
    PRIMARY KEY (container_no) USING HASH
) ENGINE=NDB COMMENT='Referentiel des conteneurs';
```

#### 3.2.2 Operations coeur (grosses tables, ecritures/scan)

```sql
-- Appels port / escales (PortCall) — une escale = un navire accoste un port
CREATE TABLE port_calls (
    call_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    vessel_id       INT UNSIGNED NOT NULL,
    port_id         INT UNSIGNED NOT NULL,
    terminal_id     INT UNSIGNED,
    arrival_at      TIMESTAMP NOT NULL,
    departure_at    TIMESTAMP NULL,
    berth_id        INT UNSIGNED NULL,
    voyage_number   VARCHAR(20),
    status          VARCHAR(20),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (call_id) USING HASH,
    KEY idx_call_vessel (vessel_id) USING HASH,
    KEY idx_call_port (port_id) USING HASH,
    KEY idx_call_arrival (arrival_at)
) ENGINE=NDB COMMENT='Escales / appels port';

-- Affectations de quai (Berth) — lien escale <-> quai avec planning
CREATE TABLE berth_assignments (
    assignment_id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    call_id         INT UNSIGNED NOT NULL,
    berth_id        INT UNSIGNED NOT NULL,
    planned_from    TIMESTAMP NOT NULL,
    planned_to      TIMESTAMP NOT NULL,
    actual_from     TIMESTAMP NULL,
    actual_to       TIMESTAMP NULL,
    activity        VARCHAR(30),
    PRIMARY KEY (assignment_id) USING HASH,
    KEY idx_assign_call (call_id) USING HASH,
    KEY idx_assign_berth (berth_id) USING HASH,
    KEY idx_assign_time (planned_from, planned_to)
) ENGINE=NDB COMMENT='Affectations de quais';

-- Operations commerciales (Operation) — chargement/dechargement par conteneur
CREATE TABLE cargo_operations (
    operation_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    call_id         INT UNSIGNED NOT NULL,
    container_no    VARCHAR(11) NOT NULL,
    operation_type  VARCHAR(15) NOT NULL,
    container_size  VARCHAR(4),
    weight_kg       INT UNSIGNED,
    cargo_type      VARCHAR(30),
    quay_crane_id   VARCHAR(10),
    operation_at    TIMESTAMP NOT NULL,
    status          VARCHAR(20),
    PRIMARY KEY (operation_id) USING HASH,
    KEY idx_op_call (call_id) USING HASH,
    KEY idx_op_container (container_no) USING HASH,
    KEY idx_op_time (operation_at)
) ENGINE=NDB COMMENT='Operations de chargement/dechargement';

-- Mouvements portail (Gate transactions) — entree/sortie camions
CREATE TABLE gate_transactions (
    gate_txn_id     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    vehicle_id      INT UNSIGNED NOT NULL,
    container_no    VARCHAR(11) NOT NULL,
    gate_id         VARCHAR(10) NOT NULL,
    direction       VARCHAR(4) NOT NULL,
    txn_at          TIMESTAMP NOT NULL,
    queue_wait_sec  INT UNSIGNED,
    appointment_id  VARCHAR(30),
    PRIMARY KEY (gate_txn_id) USING HASH,
    KEY idx_gate_vehicle (vehicle_id) USING HASH,
    KEY idx_gate_container (container_no) USING HASH,
    KEY idx_gate_time (txn_at)
) ENGINE=NDB COMMENT='Transactions portail (gate in/out)';

-- Douane (declarations / statuts)
CREATE TABLE customs_declarations (
    declaration_id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    container_no    VARCHAR(11) NOT NULL,
    call_id         INT UNSIGNED NULL,
    hs_code         VARCHAR(10),
    declared_value  DECIMAL(14,2),
    duty_amount     DECIMAL(12,2),
    status          VARCHAR(20),
    declared_at     TIMESTAMP NOT NULL,
    cleared_at      TIMESTAMP NULL,
    PRIMARY KEY (declaration_id) USING HASH,
    KEY idx_customs_container (container_no) USING HASH,
    KEY idx_customs_status (status)
) ENGINE=NDB COMMENT='Declarations douaniere';

-- Facturation / factures
CREATE TABLE invoices (
    invoice_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    call_id         INT UNSIGNED NOT NULL,
    company_id      INT UNSIGNED NOT NULL,
    invoice_number  VARCHAR(30) NOT NULL,
    amount          DECIMAL(14,2) NOT NULL,
    currency        CHAR(3) DEFAULT 'EUR',
    status          VARCHAR(20),
    invoiced_at     TIMESTAMP NOT NULL,
    due_at          DATE NULL,
    paid_at         TIMESTAMP NULL,
    PRIMARY KEY (invoice_id) USING HASH,
    KEY idx_invoice_call (call_id) USING HASH,
    KEY idx_invoice_company (company_id) USING HASH,
    KEY idx_invoice_status (status)
) ENGINE=NDB COMMENT='Facturation';

-- Stock / parc conteneurs (yard) — emplacement actuel
CREATE TABLE yard_stock (
    container_no    VARCHAR(11) NOT NULL,
    block_code      VARCHAR(10) NOT NULL,
    row_code        TINYINT UNSIGNED NOT NULL,
    tier            TINYINT UNSIGNED NOT NULL,
    in_yard_since   TIMESTAMP NOT NULL,
    PRIMARY KEY (container_no) USING HASH,
    KEY idx_yard_location (block_code, row_code)
) ENGINE=NDB COMMENT='Stock conteneurs dans le parc (yard)';
```

### 3.3 Justification des choix d'index NDB

| Table | PK | Index secondaires | Raison |
|-------|----|-------------------|--------|
| ports | INT USING HASH | — | Table de référence, accès par ID |
| berths | INT USING HASH | port_id HASH | Jointure port → quais |
| port_calls | BIGINT AUTO_INC USING HASH | vessel_id HASH, port_id HASH, arrival_at ordonné | Accès par navire/port + scans temporels |
| cargo_operations | BIGINT AUTO_INC USING HASH | call_id HASH, container_no HASH, operation_at ordonné | Coeur des requêtes d'opérations |
| gate_transactions | BIGINT AUTO_INC USING HASH | vehicle_id, container_no, txn_at ordonné | Scans par période et véhicule |
| customs_declarations | INT AUTO_INC USING HASH | container_no HASH, status HASH | Recherche statut douane |
| invoices | INT AUTO_INC USING HASH | call_id, company_id, status | Requêtes facturation |
| yard_stock | container_no USING HASH | block, row | Localisation parc |

> Note : toutes les PK utilisent `USING HASH` pour minimiser l'empreinte mémoire (21-25 octets/enregistrement au lieu de 31-35) et accélérer les écritures. Seules les colonnes de plage (dates) conservent un index ordonné (+10 octets/enregistrement).


---

## 4. Estimation du volume de données maximal (mémoire des nœuds de stockage)

### 4.1 Formule de référence (documentation MySQL NDB)

Taille RAM nécessaire par nœud de données (in-memory) :
```
RAM_par_node ≈ (TailleBase × NombreDeRéplicas × 1,1) / NombreDeNœudsDeDonnées
```

Avec **2 nœuds de stockage** (NodeId 2, 3 sur VM 2), **NoOfReplicas = 2** :
```
RAM_par_node ≈ (TailleBase × 2 × 1,1) / 2  =  TailleBase × 1,1
```
→ Chaque nœud de stockage doit pouvoir contenir **≈ 1,1 × la taille de la base** (les 2 répliques sont identiques, chacune sur un node différent mais ici les 2 nodes sont sur la MÊME VM 2).

### 4.2 Budget mémoire VM 2 (2 nœuds ndbmtd)

VM 2 : 1-2 Go RAM, 2 processus ndbmtd.

Configuration actuelle : `DataMemory = 256M`, `IndexMemory = 128M` par node.

**Important (NDB 8.0+) :** `IndexMemory` est déprécié ; les index de hache sont alloués depuis `DataMemory`. La mémoire réellement disponible pour données + index par node ≈ `DataMemory` (IndexMemory ajouté à DataMemory au démarrage si renseigné).

Avec `DataMemory = 256M` par node et 2 nodes sur VM 2 :
- Mémoire NDB totale allouée sur VM 2 ≈ 2 × 256M = 512 M (données + index combinés)
- + overhead processus ndbmtd (~100-200 Mo chacun), + OS Ubuntu (~300-500 Mo)
- Total estimé sur VM 2 ≈ 1,1 - 1,6 Go → **tient dans 2 Go, mais sans grande marge**

### 4.3 Capacité utile de données (par node group)

| Paramètre | Valeur |
|-----------|--------|
| DataMemory par node | 256 M |
| Marge de sécurité (MinFreePct 5% + overhead index/string) | ~20 % |
| DataMemory utilisable par node | ~205 M |
| Taille base max par node group | 205 M / 1,1 ≈ **185 Mo** |

→ **Volume maximal recommandé : ~150-180 Mo de données réelles (lignes + index)** sur l'ensemble du cluster, avec ~20-30 % de marge pour éviter l'erreur "Table is full" et laisser de l'OS.

### 4.4 Coût par ligne (NDB, octets)

Composants (selon MySQL 8.4 FAQ et Pro MySQL NDB Cluster) :
- Données de la ligne : somme des colonnes + overhead NDB (~8-16 octets/ligne)
- PK hash index : 21-25 octets/ligne (depuis DataMemory en NDB 8.0)
- Index ordonné : 10 octets/ligne par index ordonné
- Chaque index unique supplémentaire : +21-25 octets

**Exemple ligne `cargo_operations` (≈ 90-110 octets données) :**
- opération_id (BIGINT, 8) + call_id (INT, 4) + container_no (VARCHAR 11, ~13) + operation_type (VARCHAR 15, ~17) + taille (4) + poids (4) + type cargo (30, ~32) + crane (10, ~12) + timestamp (4) + status (20, ~22) + overhead NDB ≈ 12
- ≈ 130 octets données/ligne
- + PK hash 23 octets
- + 3 index secondaires (call_id HASH 23, container_no HASH 23, operation_at ordonné 10) ≈ 56
- **Total ≈ 209 octets/ligne** (arrondi à ~220 avec overhead page)

**À 220 octets/ligne et 185 Mo utiles :**
- ≈ 185 Mo / 220 octets ≈ **860 000 lignes** pour `cargo_operations` seul (si c'est la seule grosse table)

Réparti sur plusieurs tables avec un mix de lignes petites (référentiels, quelques milliers) et grosses (opérations, gate, yard), un volume cible réaliste :

| Table | Lignes cibles | Taille approximée |
|-------|--------------|-------------------|
| ports | 200 | négligeable |
| berths | 400 | négligeable |
| terminals | 60 | négligeable |
| vessels | 2 000 | ~0,5 Mo |
| companies | 100 | négligeable |
| vehicles | 500 | ~0,1 Mo |
| containers | 20 000 | ~2 Mo |
| port_calls | 5 000 | ~1,5 Mo |
| berth_assignments | 6 000 | ~1 Mo |
| **cargo_operations** | **300 000** | **~60-70 Mo** |
| **gate_transactions** | **400 000** | **~80-90 Mo** |
| customs_declarations | 100 000 | ~15 Mo |
| invoices | 5 000 | ~0,8 Mo |
| yard_stock | 20 000 | ~2 Mo |
| **TOTAL** | **~858 000 lignes** | **~160-180 Mo** |

**Verdict : ~800 000 à 1 million de lignes totales** constitue le volume "bonne quantité" pour des tests de performance (requêtes, jointures, scans, écritures) sans saturer les 256 Mo de DataMemory par node. C'est cohérent avec un lab de 2-3 VM à 1-2 Go RAM.

---

## 5. Stratégie de génération de données de test

### 5.1 Approche recommandée : générateur Python + import SQL

Étant donné l'absence d'Internet pendant les labs et le besoin de volumes maîtrisés, la meilleure stratégie est un **générateur synthétique Python** exécuté sur VM 1 (gestion) ou l'hôte, produisant des fichiers CSV, puis import via `LOAD DATA INFILE` ou `INSERT` par lots depuis le nœud SQL.

**Pourquoi pas import direct de dataset réel :** les datasets ouverts (Kaggle/Mendeley) sont des logs d'événements (event log), non relationnels, et nécessiteraient une normalisation lourde. Ils servent de référence pour la distribution des valeurs (codes d'activité, temps de séjour), pas de source directe.

### 5.2 Architecture du générateur

```
générateur Python (sur VM 1 ou hôte)
    │
    ├─ référentiels : ports, quais, terminaux, navires, compagnies, véhicules, conteneurs
    ├─ port_calls : escales sur N jours (ex. 90 jours), navires aléatoires
    ├─ berth_assignements : 1-3 par escale
    ├─ cargo_operations : 5-40 opérations par escale (LOAD/DISCHARGE/SHIFT)
    ├─ gate_transactions : 2-6 mouvements camion par conteneur
    ├─ customs_declarations : 1 par conteneur import/export
    ├─ invoices : 1 par escale
    └─ yard_stock : état courant des conteneurs en parc
```

**Distribution réaliste (inspirée du dataset Container Terminal Event Log / Mendeley) :**
- Activités : BAPLIE (manifest), VESSEL_ATB, DISCHARGE, STACK, CUSTOMS_DEL, TRUCK_IN, TRUCK_OUT, UNSTACK_TO_TRUCK, QUARANTINE, JOB_DEL
- Temps de séjour (dwell time) : mélange courte durée (export) et longue (import en attente douane)
- Heures : concentration diurne (6h-22h), quelques opérations de nuit

### 5.3 Méthode d'import NDB (bonnes pratiques)

Selon la documentation MySQL (Importing Data Into MySQL Cluster, NDB Cluster 8.0) et les forums officiels :

```sql
-- Sur le nœud SQL (VM 1 ou VM 3), session mysql :
SET ndb_use_transactions = 0;          -- désactive les transactions NDB pour l'import (plus rapide)
SET foreign_key_checks = 0;
SET unique_checks = 0;

-- Import par table, fichier CSV :
LOAD DATA INFILE '/tmp/seed/ports.csv'
INTO TABLE ports
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
```

**Règles d'or pour NDB (sources : manuel 25.2.7.3, 25.6.9, forums MySQL, DBA StackExchange) :**

1. **Petites transactions, pas de grosses transactions.** NDB ne gère pas bien les grosses transactions (risque de redémarrage en lecture seule / corruption). Utiliser `INSERT ... LIMIT 10000` en boucle ou `LOAD DATA` (non transactionnel sur NDB).
2. **Multi-row INSERT** par lots de 500-5 000 lignes pour réduire les allers-réseau client → nœud SQL → data nodes.
3. **`ndb_use_transactions = 0`** pour le chargement initial en vrac (permet d'exécuter un multi-row INSERT en plusieurs parties).
4. **`MaxNoOfConcurrentOperations`** (défaut 32K) : augmenter si une transaction dépasse ~32 000 opérations ; sinon garder par défaut sur ce lab (petites transactions).
5. **Ordre d'insertion :** insérer d'abord les tables de référence (ports, vessels, containers), puis les tables cœur (port_calls, cargo_operations, gate_transactions) pour éviter les références manquantes.
6. **Surveiller la mémoire pendant l'import :** `ndb_mgm -e "ALL REPORT MEMORYUSAGE"` et `SELECT ... FROM ndbinfo.memoryusage`.
7. **REDO log :** pour un gros import initial, s'assurer que `RedoBuffer` et les fichiers de journal REDO sont dimensionnés (risque "REDO log files overloaded" si transactions trop grosses).

### 5.4 Exemple de script de génération (structure, à adapter)

Un script Python génère des fichiers CSV dans `/tmp/seed_port/` sur VM 1, puis un shell les importe. Le script doit :
- Seeder les référentiels depuis les valeurs reales (UN/LOCODE des top 50 ports, IMO navires, codes activités du dataset dwelling time).
- Générer des données cohérentes (un conteneur ne peut pas être déchargé avant l'arrivée du navire, gate OUT après gate IN, etc.).
- Limiter le volume total à ~800 000 - 1 000 000 lignes pour rester sous les 180 Mo utiles.


---

## 6. Références trouvées (sites sérieux et documentation officielle)

### 6.1 Documentation MySQL NDB Cluster (Oracle)

| # | Sujet | Source |
|---|-------|--------|
| R1 | Formule mémoire NDB, coût par index (21-25 octets hash PK, 10 octets ordonné), `REPORT MEMORYUSAGE` | MySQL 8.4 / 9.1 Reference Manual — A.10 FAQ NDB Cluster : https://dev.mysql.com/doc/refman/8.4/en/faqs-mysql-cluster.html |
| R2 | DataMemory / IndexMemory (IndexMemory déprécié NDB 8.0, fusionné dans DataMemory), MaxNoOfConcurrentTransactions/Operations, MaxDMLOperationsPerTransaction | MySQL NDB Cluster 8.0 (PDF) : https://downloads.mysql.com/docs/mysql-cluster-excerpt-8.0-en.a4.pdf |
| R3 | Limites liées aux transactions NDB (petites transactions préférées, `DELETE ... LIMIT`, `LOAD DATA` non transactionnel) | MySQL 8.4 Refman — 25.2.7.3 Limits Relating to Transaction Handling : https://dev.mysql.com/doc/refman/8.4/en/mysql-cluster-limitations-transactions.html |
| R4 | Import de données dans NDB (`ndb_use_transactions=0`, `foreign_key_checks=0`, `LOAD DATA`, `ALTER TABLE ... ENGINE NDB`) | MySQL 8.0 — 25.6.9 Importing Data Into MySQL Cluster : http://docs.oracle.com/cd/E17952_01/mysql-8.0-en/mysql-cluster-importing-data.html |
| R5 | Data Node Memory Management (TransactionMemory, SharedGlobalMemory, RedoBuffer, ReservedTransactionBufferMemory) | MySQL 8.4 Refman — 25.4.3.13 : https://dev.mysql.com/doc/refman/8.4/en/mysql-cluster-data-node-memory-management.html |
| R6 | Définition des nœuds de données (MaxNoOfConcurrentTransactions default 4096, MaxNoOfConcurrentOperations default 32K, formule TotalNoOfConcurrentTransactions) | MySQL 8.4 Refman — 25.4.3.6 : https://dev.mysql.com/doc/refman/8.4/en/mysql-cluster-ndbd-definition.html |
| R7 | `ndb_size.pl` — estimateur de taille NDBCLUSTER (Chapitre 18, exemple World Database) | Pro MySQL NDB Cluster (Krogh, Okuno) — consulté via RAG local |

### 6.2 Forums et articles techniques (communauté)

| # | Sujet | Source |
|---|-------|--------|
| F1 | "Big import fail" NDB — mémoire ndbmtd, OOM killer, réduire MaxNoOfConcurrentOperations/SharedGlobalMemory, transactions plus petites, REDO log | MySQL Forums NDB clusters : https://forums.mysql.com/read.php?25,704651,704700 |
| F2 | "Insert large failed" NDB — dépassement MaxNoOfConcurrentOperations (32K default), BLOB/LONGTEXT consomment des opérations | MySQL Forums : https://forums.mysql.com/read.php?25,706646,706647 |
| F3 | "ndbcluster large transaction" — scinder avec `LIMIT`, `ndb_move_data`, éviter grosses transactions | DBA StackExchange : https://dba.stackexchange.com/questions/306085/mysql-ndb-cluster-large-transaction |
| F4 | Configurer NDB Cluster memory (DataMemory, IndexMemory, TransactionMemory, RedoBuffer), overhead OS 1-2 Go | oneuptime.com (2026) : https://oneuptime.com/blog/post/2026-03-31-mysql-configure-ndb-cluster-memory-settings/view |
| F5 | Bulk inserts MySQL (multi-row VALUES, LOAD DATA INFILE, batch 500-5000, transactions) | oneuptime.com (2026) : https://oneuptime.com/blog/post/2026-03-31-mysql-bulk-inserts-performance/view |

### 6.3 Ouvrage de référence (RAG local)

- **Pro MySQL NDB Cluster** (Jesper Wisborg Krogh, Mikiya Okuno) — indexé dans la RAG locale (`/home/yug/Documents/mysql/books/`) : Chapter 18 (`ndb_size.pl`, estimateur World Database), Chapter 9 (index stats, ANALYZE), Chapter 16 (ndbinfo, memoryusage), Chapter 21 (backup). Disponible via `python3 rag/rag-query.py`.

---

## 7. Recommandations pour ne pas dépasser les capacités des VM

### 7.1 Dimensionnement mémoire (priorité absolue)

1. **Maintenir `DataMemory = 256M` par node** (ou monter à 384M si VM 2 passe à 2 Go et que l'OS le permet). Ne pas dépasser ~50 % de la RAM de VM 2 pour les 2 ndbmtd combinés.
2. **Ne pas utiliser de grosses transactions** pendant l'import et les tests d'écriture. Limiter à quelques milliers d'opérations par transaction.
3. **Surveiller en continu** : `ndb_mgm -e "ALL REPORT MEMORYUSAGE"` avant/après chaque chargement. Alerte à 80 %, action obligatoire à 90 %.
4. **Laisser ~30-40 % de DataMemory libre** (MinFreePct = 5% par défaut, prévoir plus) pour les redémarrages de node et les opérations en cours.
5. **Éviter les colonnes TEXT/BLOB** dans les tables de test ; préférer VARCHAR borné.
6. **Limiter le nombre d'index secondaires** (chaque index consomme de la DataMemory par ligne).

### 7.2 Volume cible de test

| Métrique | Valeur recommandée |
|----------|-------------------|
| Lignes totales (toutes tables) | 700 000 - 1 000 000 |
| Poids données + index | ~150 - 180 Mo |
| Table la plus grosse (`cargo_operations` + `gate_transactions`) | ~600 000 - 700 000 lignes combinées |
| Marge mémoire sur VM 2 | ≥ 20 % DataMemory libre + RAM OS |

### 7.3 Checklist avant test de performance

- [ ] `ndb_mgm -e "SHOW"` confirme 2 data nodes connectés (NodeId 2, 3)
- [ ] `ALL REPORT MEMORYUSAGE` : DataMemory < 70 % avant chargement
- [ ] Import par petites unités, vérification mémoire entre chaque grosse table
- [ ] Requêtes de test : jointures port_calls ↔ vessels ↔ berths, scans temporels sur `cargo_operations` et `gate_transactions`, agrégations facturation, écritures simultanées depuis VM 1 et VM 3
- [ ] Sauvegarde `ndb_mgm -e "START BACKUP"` avant les tests d'écriture destructifs

---

## 8. Note importante — périmètre pédagogique

> **Ce jeu de données et ce schéma NE DOIVENT PAS apparaître dans le cours (chapitres 1 à 5).**  
> Ils sont destinés exclusivement aux **tests de performance sur les VM de laboratoire**, hors support pédagogique. Les chapitres 1-5 utilisent leurs propres jeux d'exemples et preuves (répertoire `preuves/ch*-lab*/`). Aucun contenu de ce rapport ne doit être fusionné dans les fichiers `chapitre-01.md` à `chapitre-05.md` ni dans le `syllabus.md`.

---

## 9. Prochaines étapes suggérées

1. Valider le schéma sur le cluster existant (VM 1 + VM 2 + VM 3) avec un petit volume (quelques milliers de lignes) pour confirmer le fonctionnement NDB.
2. Écrire le générateur Python + scripts d'import SQL (fichiers à placer hors du cours, ex. `tests/port_perf/`).
3. Monter progressivement le volume jusqu'à ~800 000 - 1 000 000 lignes en surveillant `ALL REPORT MEMORYUSAGE`.
4. Exécuter une batterie de requêtes de performance (scan temporel, jointure 3-4 tables, écritures concurrentes VM 1 et VM 3) et enregistrer les preuves dans `preuves/port_perf/`.

