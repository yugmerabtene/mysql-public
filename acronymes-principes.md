# Acronymes et Principes — MySQL Cluster

Ce document recense les acronymes, termes techniques et principes fondamentaux utilisés dans le parcours MySQL Cluster (5 chapitres), avec leur explication.

---

## Acronymes

| Acronyme | Signification | Explication |
|----------|---------------|-------------|
| **NDB** | Network DataBase | Moteur de stockage distribué et en mémoire de MySQL Cluster. |
| **MGM** | Management Node | Nœud de gestion du cluster. Processus : `ndb_mgmd`. |
| **MGMd** | Management Daemon | Démon du nœud de gestion (`ndb_mgmd`). |
| **ndb_mgm** | NDB Management Client | Client en ligne de commande pour administrer et superviser le cluster. |
| **ndb_mgmd** | NDB Management Daemon | Processus du nœud de gestion. Charge et distribue `config.ini`. |
| **ndbmtd** | NDB Data Node Multi-Threaded | Implémentation multi-thread du nœud de stockage. |
| **ndbd** | NDB Data Node | Implémentation mono-thread du nœud de stockage. |
| **mysqld** | MySQL Daemon | Serveur MySQL. Dans MySQL Cluster, il agit comme nœud SQL (API). |
| **SQL Node** | Nœud SQL | Nœud exécutant `mysqld` avec le moteur NDB. Interface SQL du cluster. |
| **Data Node** | Nœud de stockage | Nœud hébergeant les fragments de données (processus `ndbmtd` ou `ndbd`). |
| **Management Node** | Nœud de gestion | Nœud distribuant la configuration du cluster (`ndb_mgmd`). |
| **API Node** | Nœud API | Terme générique désignant un nœud SQL (accède au cluster via l'API NDB). |
| **VM** | Virtual Machine | Machine virtuelle. Dans ce lab : Ubuntu Server 24.04 LTS. |
| **LCP** | Local Checkpoint | Point de contrôle local. Sauvegarde périodique des données modifiées sur disque par chaque nœud de stockage. |
| **GCP** | Global Checkpoint | Point de contrôle global. Marque un point de synchronisation global entre tous les nœuds pour la cohérence transactionnelle. |
| **HA** | High Availability | Haute disponibilité. Capacité du cluster à rester opérationnel malgré la défaillance d'un nœud. |
| **SPOF** | Single Point of Failure | Point de défaillance unique. Architecture visant à l'éliminer (shared-nothing). |
| **NDB Cluster** | MySQL NDB Cluster | Technologie de cluster MySQL basée sur le moteur NDB, haute disponibilité et scalabilité horizontale. |

---

## Principes et concepts

| Principe | Explication |
|----------|-------------|
| **Shared-Nothing** | Architecture où chaque nœud possède sa propre mémoire et ses propres disques. Les données sont fragmentées et répliquées sur plusieurs nœuds indépendants. Aucun point de défaillance unique. |
| **NoOfReplicas** | Nombre de copies de chaque fragment de données. Valeur `2` dans ce lab pour tolérer la perte d'un nœud de stockage. |
| **Node-group** | Groupe de nœuds de stockage contenant les mêmes copies de données. Avec `NoOfReplicas = 2` et 2 nœuds de stockage, le cluster forme un node group unique. |
| **Quorum** | Règle de décision par majorité (N/2 + 1) empêchant deux partitions d'agir simultanément. **N/2 + 1** signifie qu'il faut la moitié des nœuds plus un vote pour valider une décision. Exemple : avec 3 nœuds de gestion, il faut 2 votes sur 3. Seul le groupe majoritaire peut agir ; l'autre groupe se met en arrêt pour prévenir le split-brain. |
| **Split-brain** | Situation où le cluster est partitionné en deux groupes ne pouvant plus communiquer. |
| **Arbitrage** | Mécanisme par lequel un nœud tranche en cas de perte de communication entre node groups. |
| **Failover** | Basculement automatique sur un nœud de réplica lorsqu'un nœud primaire tombe en panne. |
| **Failback** | Retour arrière vers le nœud primaire après sa réparation et réintégration. |
| **Redémarrage rolling** | Redémarrage d'un nœud un par un sans arrêter l'ensemble du cluster (maintenance à chaud). |
| **Connect-string** | Adresse du nœud de gestion donnée à chaque node pour rejoindre le cluster (ex. `192.168.56.10`). |
| **NodeId** | Identifiant unique de chaque nœud dans le cluster (1 à 5 dans ce lab). |
| **DataDir** | Répertoire de stockage des données et fichiers de cluster sur chaque nœud. |
| **DataMemory** | Mémoire allouée au stockage des données par chaque nœud de stockage. |
| **IndexMemory** | Mémoire allouée aux index par chaque nœud de stockage. |
| **Sauvegarde cluster** | Opération `START BACKUP` créant une sauvegarde cohérente de l'ensemble du cluster. |
| **Restauration** | Opération `ndb_restore` restaurant une sauvegarde sur le cluster. |
| **Moindre privilège** | Principe de sécurité accordant uniquement les permissions nécessaires à chaque compte SQL. |
| **Isolement réseau** | Absence d'accès Internet sur les nœuds de production/lab pour limiter la surface d'attaque. |

---

## Nœuds et adresses du lab

| VM | Hostname | Adresse IP | Rôle | NodeId |
|----|----------|------------|------|--------|
| VM 1 | gestion-sql | 192.168.56.10 | Nœud de gestion + nœud SQL | 1 (MGM), 4 (SQL) |
| VM 2 | stockage | 192.168.56.11 | Deux nœuds de stockage | 2, 3 (NDB) |
| VM 3 | mysql-node3 | 192.168.56.12 | Second nœud SQL | 5 (SQL) |

---

## Ordre de démarrage critique

1. **Nœud de gestion** (`ndb_mgmd`, NodeId 1) — lit `config.ini` et devient maître de configuration.
2. **Nœuds de stockage** (`ndbmtd`, NodeId 2 et 3) — se déclarent au gestionnaire et forment le node group.
3. **Nœuds SQL** (`mysqld`, NodeId 4 et 5) — se connectent au gestionnaire et activent le moteur NDB.

---

## Fichiers de configuration

| Fichier | Rôle |
|---------|------|
| `config.ini` | Fichier de topologie du cluster définissant `NodeId`, `HostName`, `DataDir`, `NoOfReplicas`, `DataMemory`, `IndexMemory`. |
| `netplan` | Configuration IP statique des VMs. |

---


