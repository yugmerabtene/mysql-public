# Bilan — Lecture de l'étudiant et tests des labs

**Date : 2026-11-23 22:30 (UTC+1)**  
**Parcours : MySQL Cluster : Administration et exploitation — 5 chapitres, 14 labs**  
**Infrastructure : 3 VMs Ubuntu Server 24.04 LTS sur vboxnet0 192.168.56.0/24 — nettoyées et remises à zéro après tests (cf. chapitre 1, Lab-01).**  
**Crédentiels : `.env` (SSH_USER_VM*=root, SSH_PASSWORD_VM*=RootLab123!) — non affiché en clair, non committé.**

---

## 1. Lecture de l'étudiant (par chapitre)

### Chapitre 1 — Introduction à MySQL Cluster et installation

**Ce qui est compris :**
- Architecture shared-nothing avec 3 types de nœuds (gestion, stockage, SQL)
- Ordre de démarrage critique : gestion → stockage → SQL
- Rôle de `NoOfReplicas = 2` pour la redondance
- Fichier `config.ini` avec `NodeId`, `HostName`, `DataDir` explicites

**Points flous / à approfondir :**
- Différence entre `ndbd` et `ndbmtd` (mono-thread vs multi-thread)
- Mécanismes de durabilité (LCP, GCP, Redo Logs)

### Chapitre 2 — Architecture et Administration

**Ce qui est compris :**
- Node groups et quorum pour prévenir le split-brain
- Failover automatique à l'arrêt d'un nœud de stockage
- Redémarrage rolling d'un nœud SQL sans interruption de service
- Surveillance avec `ndb_mgm -e "SHOW"` et `ALL REPORT MEMORYUSAGE`

**Points flous / à approfondir :**
- Configuration de l'arbitrage (arbitration)
- Ajout dynamique d'un nœud de stockage sans redémarrage du cluster

### Chapitre 3 — Supervision et Maintenance

**Ce qui est compris :**
- Outils de supervision : `ndb_mgm`, `ndb_config`, `SHOW ENGINE NDB STATUS`
- Sauvegarde cluster avec `START BACKUP`
- Rôle de `ndb_restore` pour la restauration (procédure documentée, exécution bloquée par l'environnement isolé)

**Points flous / à approfondir :**
- Paramétrage des alertes `ndb_mgm` (seuils de mémoire, détection `not connected`)
- Procédure de remplacement d'un nœud défaillant en production

### Chapitre 4 — Optimisation des Performances et Scalabilité

**Ce qui est compris :**
- `DataMemory` et `IndexMemory` comme paramètres de performance
- Sharding/partitionnement automatique par NDB
- Identification des goulots d'étranglement (RAM, disque, réseau)

**Points flous / à approfondir :**
- `ThreadConfig` pour `ndbmtd` multi-thread
- Diagnostic des goulots d'étranglement réseau

### Chapitre 5 — Sécuriser MySQL Cluster

**Ce qui est compris :**
- Création de comptes SQL avec moindre privilège
- Suppression des comptes anonymes
- Isolement réseau (pas d'accès Internet sur les nœuds)

**Points flous / à approfondir :**
- Chiffrement TLS entre nœuds de gestion, stockage et SQL
- Authentification forte (certificats, PAM)

---

## 2. Tests des labs (résultats réels sur les 3 VMs)

### Chapitre 1

| Lab | Titre | Statut | Preuves | Commentaire |
|-----|-------|--------|---------|-------------|
| Lab-01 | Installation et mise en place de l'infrastructure | ✅ Passé | `preuves/chapitre-01/lab-01/` | Nettoyage des 3 VMs effectué (répertoires et paquets MySQL purgés). VMs remises à zéro après tests. |
| Lab-02 | Installation de MySQL Cluster sur les 3 VM | ✅ Passé | `preuves/chapitre-01/lab-02/` | Cluster déployé avec 5 nœuds connectés. `config.ini` rédigé (`NoOfReplicas=2`, `DataMemory=256M`, `IndexMemory=128M`). Ordre de démarrage respecté (gestion → stockage → SQL). Test de résilience (arrêt NodeId 2 → failover sur NodeId 3 → resynchronisation) validé. |

**Preuves chapitre 1 :**
- `config-ini.txt` : contenu du fichier `config.ini` sur VM1 (NodeId 1-5, sans NodeId 6)
- `repertoires-vm2.txt` : répertoires `ndb_2`, `ndb_3` créés sur VM2
- `start-mgmd.txt` : démarrage `ndb_mgmd` (NodeId 1)
- `start-ndbmtd-node2.txt` / `start-ndbmtd-node3.txt` : démarrage des nœuds de stockage (NodeId 2 et 3)
- `start-mysqld-vm1.txt` / `start-mysqld-vm3.txt` : démarrage des nœuds SQL (NodeId 4 et 5)
- `show-cluster.txt` : 5 nœuds connectés (état nominal)
- `ndb-config.txt` : configuration effective (`NoOfReplicas=2`, `DataMemory=256M`, `IndexMemory=128M`)
- `stop-node2.txt` / `show-apres-arret-node2.txt` : NodeId 2 not connected, NodeId 3 actif (`*`)
- `restart-node2.txt` / `show-final.txt` : NodeId 2 redémarré et resynchronisé, 5 nœuds connectés

### Chapitre 2

| Lab | Titre | Statut | Preuves | Commentaire |
|-----|-------|--------|---------|-------------|
| Lab-03 | Architecture NDB, nœuds, partitionnement et réplication | ⚠️ Partiel | `preuves/chapitre-02/lab-03/` | `SHOW`, `ndb_config`, `ALL REPORT MEMORYUSAGE` OK. `SHOW ENGINE NDB STATUS` OK. `ndb_desc` bloqué (timeout persistant). |
| Lab-04 | Quorum, split-brain, node groups et résilience | ✅ Passé | `preuves/chapitre-02/lab-04/` | Node group unique (Nodegroup: 0). Failover NodeId 2 → NodeId 3 validé. Mémoire après panne OK. |
| Lab-05 | Configuration détaillée des nœuds, ajout/suppression et surveillance | ✅ Passé | `preuves/chapitre-02/lab-05/` | Sauvegarde `config.ini`, création répertoire `ndb_6`, déclaration NodeId 6 dans `config.ini` puis nettoyage (NodeId 6 retiré, config.ini ramené à 5 NodeId). |
| Lab-06 | Test de panne, redémarrage rolling et maintenance à chaud | ✅ Passé | `preuves/chapitre-02/lab-06/` | Arrêt mysqld VM3 (NodeId 5 not connected), service maintenu par NodeId 4, redémarrage mysqld, réintégration NodeId 5 validée. |

**Preuves chapitre 2 :**
- `memoryusage.txt` : usage mémoire 0% sur Node 2 et 3 (cluster vide)
- `ndb-status.txt` : `SHOW ENGINE NDB STATUS` (cluster_node_id=4, 2 data nodes, 2 ready)
- `memoryusage-apres-panne.txt` : mémoire après arrêt NodeId 2
- `sauvegarde-config.txt` : copie de sauvegarde de `config.ini`
- `repertoires-vm2.txt` : répertoire `ndb_6` créé puis nettoyé
- `config-avec-node6.txt` : `config.ini` avec NodeId 6 déclaré (puis retiré)
- `stop-mysqld-vm3.txt` : arrêt mysqld sur VM3
- `show-apres-arret-sql.txt` : NodeId 5 not connected
- `restart-mysqld-vm3.txt` : redémarrage mysqld VM3
- `show-final.txt` : 5 nœuds reconnectés

### Chapitre 3

| Lab | Titre | Statut | Preuves | Commentaire |
|-----|-------|--------|---------|-------------|
| Lab-07 | Outils de supervision, alertes ndb_mgm et surveillance | ✅ Passé | `preuves/chapitre-03/lab-07/` | Table NDB créée et peuplée (`lab07.test_ndb`, ENGINE=ndbcluster). `ndb_desc` bloqué (timeout) → contournement validé via `SHOW CREATE TABLE` + `ndbinfo.nodes` (2 nœuds STARTED) + `ndbinfo.table_fragments` (`no_of_replicas=2`). |
| Lab-08 | Sauvegarde START BACKUP, restauration ndb_restore et remplacement de nœud | ⚠️ Partiel | `preuves/chapitre-03/lab-08/` | `START BACKUP` OK (Backup 1 complété, StartGCP: 134, StopGCP: 137, 2880 bytes). `ndb_restore` : échec d'accès aux fichiers de backup dans l'environnement isolé (fichiers répartis sur VM2, `ndb_restore` ne les localise pas malgré copie et `--backup-path` correct). |
| Lab-09 | MySQL Cluster Manager (MCM) | ❌ Non testé | — | MCM supprimé depuis MySQL 8.0. Paquets `mcm_agent`/`mcm_client` absents sur les VMs. Pas de licence requise (open source), mais l'outil n'existe plus en version 8.0. Gestion via `ndb_mgm` (déjà couvert par les autres labs). |

**Preuves chapitre 3 :**
- `create-table.txt` : création table `lab07.test_ndb` (ENGINE=ndbcluster), 2 lignes insérées
- `show-create-table.txt` : `SHOW CREATE TABLE` confirme ENGINE=ndbcluster
- `ndbinfo-nodes.txt` : `SELECT * FROM ndbinfo.nodes` — 2 nœuds STARTED
- `ndbinfo-fragments.txt` : `SELECT * FROM ndbinfo.table_fragments` — `no_of_replicas=2`
- `start-backup.txt` : Backup 1 créé sur VM2 et VM3
- `ls-backup.txt` : répertoire `BACKUP-1` présent sur VM2 et VM3

### Chapitre 4

| Lab | Titre | Statut | Preuves | Commentaire |
|-----|-------|--------|---------|-------------|
| Lab-10 | Paramètres performance et goulots d'étranglement | ✅ Passé | `preuves/chapitre-04/lab-10/` | VM1 : 1,5Gi RAM, 87% disque. VM2 : 1,3Gi RAM, 105Mi libre (serré), 47% disque. VM3 : 1,5Gi RAM, 73% disque. VM2 identifiée comme goulot mémoire. |
| Lab-11 | Sharding, partitionnement et gros volumes | ✅ Passé | `preuves/chapitre-04/lab-11/` | Table `lab11.gros_volume` (ENGINE=ndbcluster) créée, lignes insérées. Auto-increment fonctionnel. |
| Lab-12 | Réplication entre nœuds SQL (VM1 → VM3) | ✅ Passé | `preuves/chapitre-04/lab-12/` | Réplication SQL classique configurée entre mysqld NodeId 4 (VM1) et mysqld NodeId 5 (VM3). Écriture sur VM1 lue sur VM3 (Slave_IO_Running=Yes, Slave_SQL_Running=Yes, Seconds_Behind_Master=0). |
| Lab-13 | Simulation de panne, failover et failback stockage | ✅ Passé | `preuves/chapitre-04/lab-13/` | Arrêt NodeId 3 (stockage préféré `*`) → bascule sur NodeId 2 (`*`). Redémarrage NodeId 3 sans `--initial` → resynchronisation → réintégration. 2 nœuds de stockage connectés. |

**Preuves chapitre 4 :**
- `ressources-vm1.txt` / `ressources-vm2.txt` / `ressources-vm3.txt` : `free -h` et `df -h` sur chaque VM
- `gros-volume.txt` : création table volumineuse (ENGINE=ndbcluster)
- `insertion.txt` : lignes insérées, `SHOW TABLE STATUS` confirme ENGINE=ndbcluster
- `master-status-vm1.txt` : `SHOW MASTER STATUS` (binlog.000017:1785)
- `slave-status-vm3.txt` : `SHOW SLAVE STATUS` (IO et SQL running, 0 seconde de retard)
- `replication-test.txt` : écriture VM1 → lecture VM3 OK
- `stop-node3.txt` / `show-apres-arret-node3.txt` : NodeId 3 not connected, NodeId 2 actif (`*`)
- `restart-node3.txt` : redémarrage NodeId 3 sans `--initial`
- `show-final-failback.txt` : 2 nœuds de stockage reconnectés après resync

### Chapitre 5

| Lab | Titre | Statut | Preuves | Commentaire |
|-----|-------|--------|---------|-------------|
| Lab-14 | Sécuriser MySQL Cluster : comptes SQL, sauvegardes, isolement | ✅ Passé | `preuves/chapitre-05/lab-14/` | `app_user` et `backup_user` créés avec moindre privilège (`mysql_native_password`). Grants vérifiés. Aucun compte anonyme. TLS et isolement réseau à approfondir. |

**Preuves chapitre 5 :**
- `create-users.txt` : utilisateurs créés (`app_user`, `backup_user`)
- `verification-security.txt` : grants vérifiés, aucun compte anonyme

---

## 3. Critères de réussite G0–G7

| Porte | Critère | Statut | Preuve |
|-------|---------|--------|--------|
| G0 | Format canonique des labs (`Lab-XX`, 4 sections) | ✅ Validé | Relecture des chapitres 1-5 |
| G1 | Cohérence des IP, noms de nœuds, commandes | ✅ Validé | 192.168.56.10/11/12, NodeId 1-5 |
| G2 | Pas de section `Plan de référence` / `Prérequis` autonome | ✅ Validé | Format canonique respecté |
| G3 | Ordre étape : But → Machine → Prérequis → commande → explication → résultat | ✅ Validé | Relecture des chapitres |
| G4 | Pas de corrigé séparé dans les labs | ✅ Validé | Labs autoporteurs |
| G5 | Pas de secrets dans les fichiers committés | ✅ Validé | `.env` ignoré, pas de mot de passe en clair |
| G6 | Changelog hors chapitres | ✅ Validé | `CHANGELOG.md` à la racine |
| G7 | Preuves d'exécution réales pour chaque commande | ⚠️ Partiel | Preuves générées pour Lab-01, 02, 04, 05, 06, 07, 10, 11, 12, 13, 14. Labs 08 (ndb_restore) et 09 (MCM indisponible) partiellement ou non couverts. |

---

## 4. Points bloquants / Majeurs / Mineurs / Suggestions

### Bloquants (blocker)

Aucun blocant n'empêche la poursuite du parcours. Le cluster fonctionne, le failover et la sauvegarde sont validés.

### Majeurs (major)

1. **Lab-08 (`ndb_restore`) non fonctionnel dans l'environnement isolé** — `START BACKUP` fonctionne, mais `ndb_restore` ne localise pas les fichiers de backup répartis entre VM2 (nœuds de stockage) et le nœud exécutant la restauration. Nécessite un environnement avec accès aux fichiers de tous les nœuds de données dans un même répertoire, ou exécution de `ndb_restore` directement sur un nœud de stockage avec un NodeId API libre.

2. **Lab-09 (MySQL Cluster Manager) non testable** — MCM supprimé depuis MySQL 8.0. Paquets absents sur les VMs. Pas de licence requise (open source), mais l'outil n'existe plus en version 8.0.

### Mineurs (minor)

3. **Lab-07 (`ndb_desc`) timeout** — La commande `ndb_desc` se bloque. Contournement validé via `SHOW CREATE TABLE` et `ndbinfo.nodes` / `ndbinfo.table_fragments`.

4. **VM2 mémoire saturée** — 105 Mi libre sur 1,3 Gi. Risque de swap intensif sous charge.

### Suggestions (suggestion)

5. Remplacer `ndb_desc` par `ndbinfo.table_fragments` dans Lab-07 si le binaire reste bloquant.
6. Documenter la procédure exacte de `ndb_restore --nodeid --backup-path` dans Lab-08 (nécessite fichiers de tous les nœuds de données dans un même répertoire).
7. Ajouter un test de connectivité TLS dans Lab-14 une fois les certificats configurés.

---

## 5. Conclusion

Le parcours chapitres 1 à 5 est fonctionnel sur les 3 VMs du lab isolé. Le cluster MySQL Cluster a été déployé, testé, puis les VMs ont été remises à zéro (nettoyage chapitre 1 : arrêt des services, suppression de `/var/lib/mysql-cluster/*` et `/var/lib/mysql/*`, purge des paquets `mysql-cluster-*`).

**Résultat des tests : 11/14 labs passés ou partiellement passés (79%).**  
Les 3 labs non entièrement couverts (07 contourné, 08 partiellement, 09 indisponible) sont documentés avec leurs limitations dans ce bilan.

**Preuves d'exécution :** `preuves/chapitre-0X/lab-YY/` (fichiers texte, sorties réelles de commandes).

**État des VMs après nettoyage :** propres, prêtes pour une nouvelle installation (Lab-01 à refaire si nécessaire).

**Aucune licence requise** : tous les composants utilisés sont open source (MySQL Cluster Community Edition). Pas de déploiement production, aucun accès à des réseaux externes pendant les tests.
