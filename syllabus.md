# Syllabus — MySQL Cluster : Administration et exploitation (source de vérité du cours)

## Ressources matérielles (lab isolé)

- Maximum 3 VMs, idéalement 2 VMs, pour préserver la machine hôte.
- Par VM : 1 vCPU, 1 Go RAM, 15 Go disque dur.
- Système : Ubuntu Server 24.04 LTS.
- Réseau : VirtualBox Host-only vboxnet0, 192.168.56.0/24, DHCP désactivé, pas d'accès Internet pendant les labs.
- Hôte : 192.168.56.1.
- VM 1 (192.168.56.10) : nœud de gestion + nœud SQL.
- VM 2 (192.168.56.11) : deux nœuds de stockage (ndbmtd node-id 1 et 2).

## Objectifs pédagogiques

1. Comprendre l'architecture de MySQL Cluster
2. Installer et configurer un cluster MySQL
3. Gérer la réplication et la tolérance aux pannes
4. Optimiser les performances et la scalabilité
5. Superviser et maintenir un cluster MySQL en production
6. Utiliser les architectures shared-disk et shared-nothing
7. Mettre en place et configurer un proxy pour MySQL Cluster
8. Assurer la résilience des nœuds et prévenir le split-brain
9. Détecter et récupérer des nœuds défaillants sans interruption de service
10. Analyser les goulots d'étranglement (réseau, disque, RAM)
11. Sécuriser les communications inter-nœuds

## Programme

### Jour 1 – Introduction à MySQL Cluster

#### 1.0 — Introduction à MySQL Cluster — Architecture et composants (3 h)

Présentation de MySQL Cluster et de son architecture
Les composants principaux : MySQL Server, NDB Cluster, management nodes
Pourquoi MySQL Cluster est-il adapté aux applications critiques ?
Études de cas et exemples d'utilisation
Travaux pratiques : exploration des composants de MySQL Cluster à travers des exemples concrets et des études de cas

#### 1.1 — Installation de MySQL Cluster (3 h)

Pré-requis matériels et logiciels, avec dimensionnement de résilience dès l'installation (`NoOfReplicas = 2`, ordre de démarrage critique : gestion → stockage → SQL)
Installation des différents composants du cluster
Configuration initiale et démarrage des services dans l'ordre requis
Comment vérifier l'intégrité de l'installation ?
Travaux pratiques : mise en place d'un environnement de test, installation des composants, configuration de la redondance et vérification du bon fonctionnement du cluster

### Jour 2 – Architecture et Administration de MySQL Cluster

#### 2.0 — Architecture de MySQL Cluster — Nœuds, partitionnement, réplication (3 h)

Le moteur de stockage NDB
Différents types de nœuds
Partitionnement et réplication
Redondance et résilience
**Ajout résilience :** quorum et arbitrage pour prévenir le split-brain, configuration des node groups pour survivre à la perte d'un nœud de stockage, détection des goulots d'étranglement (réseau, disque, RAM)

#### 2.1 — Configuration et Administration — Nœuds de gestion, stockage, SQL (3 h)

Configurer les nœuds de gestion, de stockage et SQL
Paramètres de configuration essentiels
Ajout et suppression de nœuds dans le cluster
Comment surveiller l'état du cluster ?
**Ajout résilience :** test de panne (arrêt d'un `ndbmtd`, observation `ndb_mgm -e "SHOW"`, mesure du temps de récupération), redémarrage rolling d'un nœud SQL sans arrêt du cluster (maintenance à chaud)
Travaux pratiques : configuration détaillée des nodes, gestion des ajouts et suppressions, et mise en place des outils de surveillance

### Jour 3 – Supervision et Maintenance

#### 3.0 — Supervision et Maintenance (3 h)

Outils de supervision et d'alertes
Tâches de maintenance courantes
Sauvegarde et restauration de données
Comment assurer une maintenance sans interruption de service ?
**Ajout résilience :** alertes `ndb_mgm` quand un nœud passe en `not connected`, surveillance des ports MGM (1186) et SQL (3306), sauvegarde cluster `ndb_mgm -e "START BACKUP"` + restauration `ndb_restore` validée, procédure de remplacement d'un nœud défaillant sans interruption de service
Travaux pratiques : configuration des outils de supervision, planification des tâches de maintenance et mise en œuvre des stratégies de sauvegarde et de restauration

#### 3.1 — MySQL Cluster Manager (3 h)

Installer les agents et clients MySQL Cluster Manager
Création de clusters
Importer des configurations
Maintenance et gestion de clusters
Travaux pratiques : installation et configuration de MySQL Cluster Manager

### Jour 4 – Optimisation des Performances et Scalabilité

#### 4.0 — Optimisation des Performances et Scalabilité (3 h)

Paramètres de performance à optimiser
Techniques de sharding et de partitionnement
Comment diagnostiquer et résoudre les problèmes de performance ?
Études de cas de performance
**Ajout résilience :** identification des goulots d'étranglement (saturation réseau, limite RAM, disque), sharding/partitionnement pour répartir la charge sur plusieurs nœuds de stockage
Travaux pratiques : mise en œuvre de techniques d'optimisation et résolution de problèmes de performance sur un cluster MySQL

#### 4.1 — Gestion de la Réplication et de la Tolérance aux Pannes (3 h)

Concepts de réplication en MySQL Cluster
Configurer la réplication entre clusters
Gestion des pannes et des récupérations
Mécanismes de failover et de failback
**Ajout résilience :** réplication entre clusters (site principal → site de secours), simulation de panne, basculement (failover) et retour arrière (failback)
Travaux pratiques : configuration de la réplication, simulation de pannes et mise en place des stratégies de récupération

### Jour 5 – Sécuriser MySQL Cluster

#### 5.0 — Sécuriser MySQL Cluster (6 h)

Sécurité des connexions
Sécurité des données
Sécurité des nœuds serveurs
**Ajout résilience :** chiffrement TLS entre nœuds de gestion, stockage et SQL, authentification forte, moindre privilège sur les comptes du cluster, isolement réseau (pas d'accès Internet sur les nœuds de production)
Travaux pratiques : configuration de la sécurité d'un cluster MySQL

## Référentiel de référence des opérations (NDB-nn)

| Jour | Module | Thème | Opérations de référence |
|---|---|---|---|
| 1 | 1.0 | Introduction et architecture | `NDB-01` Présentation des composants · `NDB-02` Études de cas |
| 1 | 1.1 | Installation | `NDB-03` Installation composants · `NDB-04` Configuration initiale · `NDB-05` Vérification intégrité · `NDB-08` Dimensionnement résilience |
| 2 | 2.0 | Architecture | `NDB-06` Moteur NDB · `NDB-07` Types de nœuds · `NDB-09` Quorum et split-brain · `NDB-10` Node groups |
| 2 | 2.1 | Configuration et administration | `NDB-11` Configuration nœuds · `NDB-12` Ajout/suppression nœuds · `NDB-13` Surveillance état · `NDB-14` Test de panne · `NDB-15` Redémarrage rolling |
| 3 | 3.0 | Supervision et maintenance | `NDB-16` Outils de supervision · `NDB-17` Tâches maintenance · `NDB-18` Sauvegarde/restauration · `NDB-19` Remplacement nœud défaillant |
| 3 | 3.1 | MySQL Cluster Manager | `NDB-20` Installation agents · `NDB-21` Création clusters · `NDB-22` Gestion clusters |
| 4 | 4.0 | Optimisation et scalabilité | `NDB-23` Paramètres performance · `NDB-24` Goulots d'étranglement · `NDB-25` Sharding/partitionnement |
| 4 | 4.1 | Réplication et tolérance aux pannes | `NDB-26` Réplication inter-clusters · `NDB-27` Gestion pannes · `NDB-28` Failover/failback |
| 5 | 5.0 | Sécuriser MySQL Cluster | `NDB-29` Sécurité connexions · `NDB-30` Sécurité données · `NDB-31` Sécurité nœuds |

## Source de vérité

Ce fichier `syllabus.md` est la source de vérité unique du cours. Tous les agents (`orchestrator`, `prof`, `student`, `sysadmin`) s'y réfèrent pour la structure, les modules, les durées, les opérations de référence et les ajouts résilience. Le fichier `syllabusOriginal.md` est conservé comme référence historique mais n'est plus le document de travail.
