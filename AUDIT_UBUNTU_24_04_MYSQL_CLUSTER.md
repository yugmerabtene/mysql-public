# AUDIT — Cours MySQL Cluster (chapitres 1 à 5, Lab-01 à Lab-14) — Compatibilité Ubuntu 24.04 LTS

**Dépôt audité :** `/home/yug/Documents/mysql`
**Fichiers de cours :** chapitre-01.md … chapitre-05.md (format markdown, labs canoniques intégrés)
**Infrastructure cible :** 3 VMs Ubuntu Server 24.04 LTS sur vboxnet0 192.168.56.0/24 (DHCP off)
- VM 1 `192.168.56.10` `gestion-sql` : ndb_mgmd NodeId 1 + mysqld NodeId 4
- VM 2 `192.168.56.11` `stockage` : ndbmtd NodeId 2 et NodeId 3 (répertoires ndb_2, ndb_3)
- VM 3 `192.168.56.12` `mysql-node3` : mysqld NodeId 5
**Hôte :** 192.168.56.1 (hyperviseur, administration, preuves)
**Binaires :** ndb_mgmd, ndbmtd, mysqld, ndb_mgm, ndb_config, ndb_restore, ndb_desc, mysql (8.0.50-cluster)

---

## 1. CARTOGRAPHIE EXHAUSTIVE

### Légende des colonnes du tableau
`Chap → Lab → Étape → But → Commande exacte (bash / SQL) → Prérequis déclarés → Résultat attendu dans le cours`

### CHAPITRE 1 — Installation et intégrité du cluster

#### Lab-01 — Installation et mise en place de l'infrastructure (vierge ou remise à zéro)

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 (Cas A) VM1 | Nettoyer VMs existantes | `rm -rf /var/lib/mysql-cluster /usr/mysql-cluster /etc/mysql /var/lib/mysql` | VMs démarrées, SSH root ouverte | sortie vide, rc=0 |
| 1 (Cas A) VM2 | idem VM2 | `rm -rf /var/lib/mysql-cluster /usr/mysql-cluster /etc/mysql /var/lib/mysql` | idem | sortie vide, rc=0 |
| 1 (Cas A) VM3 | idem VM3 | `rm -rf /var/lib/mysql-cluster /usr/mysql-cluster /etc/mysql /var/lib/mysql` | idem | sortie vide, rc=0 |
| 1b (Cas A) VM1 | Purger paquets MySQL | `apt-get purge -y mysql-cluster-* mysql-server-* mysql-common-* || true` | Étape 1 faite | sortie vide, rc=0 |
| 1b (Cas A) VM2 | idem VM2 | `apt-get purge -y mysql-cluster-* mysql-server-* mysql-common-* || true` | idem | sortie vide, rc=0 |
| 1b (Cas A) VM3 | idem VM3 | `apt-get purge -y mysql-cluster-* mysql-server-* mysql-common-* || true` | idem | sortie vide, rc=0 |
| 1c (Cas A) VM1 | Suppr. dépendances orphelines | `apt-get autoremove -y || true` | Étape 1b faite | sortie vide, rc=0 |
| 1c (Cas A) VM2 | idem VM2 | `apt-get autoremove -y || true` | idem | sortie vide, rc=0 |
| 1c (Cas A) VM3 | idem VM3 | `apt-get autoremove -y || true` | idem | sortie vide, rc=0 |
| 2 (Cas B) Hôte | Créer réseau host-only vboxnet0 | (GUI VirtualBox : Fichier → Gestionnaire de réseaux → Réseaux privés d'hôte ; vboxnet0 192.168.56.1/255.255.255.0, DHCP désactivé) | VirtualBox installé | vboxnet0 créé, DHCP off |
| 3 (Cas B) Hôte | Créer 3 VMs | (GUI VirtualBox : UbuntuServer-01/02/03, 1 vCPU, 1 Go RAM, 15 Go, ISO Ubuntu 24.04, boot DVD avant disque) | vboxnet0 créé, ISO dispo | 3 VMs créées |
| 4 (Cas B) Hôte | Configurer adaptateurs réseau | (GUI : adaptateur 1 = host-only vboxnet0, adaptateur 2 = NAT sur chaque VM) | 3 VMs créées, vboxnet0 créé | 2 adaptateurs/VM |
| 5 (Cas B) VMs | Installer Ubuntu Server | (aucune commande : installation GUI depuis ISO ; utilisateur root + mot de passe, SSH root activé) | VMs créées, ISO attaché, réseaux configurés | Ubuntu 24.04 LTS installé |
| 6 VM1 | IP statique + SSH (gestion-sql) | `hostnamectl set-hostname gestion-sql` ; `tee /etc/netplan/01-netcfg.yaml << 'YEOF' ... enp0s8 ... addresses: [192.168.56.10/24] ...` ; `netplan apply` ; `systemctl enable --now ssh` | Ubuntu 24.04 installé, accès root, adaptateur host-only présent | `gestion-sql`, IP appliquée, SSH actif |
| 6 VM2 | IP statique + SSH (stockage) | `hostnamectl set-hostname stockage` ; netplan `enp0s8` `192.168.56.11/24` ; `netplan apply` ; `systemctl enable --now ssh` | idem | `stockage` |
| 6 VM3 | IP statique + SSH (mysql-node3) | `hostnamectl set-hostname mysql-node3` ; netplan `enp0s8` `192.168.56.12/24` ; `netplan apply` ; `systemctl enable --now ssh` | idem | `mysql-node3` |
| 7 Hôte | Vérifier IP + connectivité | `ping -c 4 192.168.56.10/11/12` ; sur chaque VM `hostname` et `ip -br addr show enp0s8` | IP statiques configurées, SSH actif | 0% perte, IP `192.168.56.10/11/12/24` sur enp0s8 |
| 8 Hôte | Snapshots propres | `VBoxManage snapshot UbuntuServer-01 list` ; `VBoxManage snapshot UbuntuServer-02 list` ; `VBoxManage snapshot UbuntuServer-03 list` | VirtualBox, VMs existent | `propre-avant-lab` présent sur chaque VM |

Fichiers de config créés : `/etc/netplan/01-netcfg.yaml` (VM1/2/3, interface `enp0s8`).
Preuves référencées : aucune path `preuves/` explicite dans le lab (convention AGENTS.md uniquement).

#### Lab-02 — Installation de MySQL Cluster sur les 3 VM

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | Vérifier paquets Cluster VM1 | `dpkg -l` | VM1 démarrée, SSH root | 4 paquets `mysql-cluster-community-*` 8.0.50 (si déjà installés) |
| 2 VM2 | Vérifier paquets Cluster VM2 | `dpkg -l` | VM2 démarrée, SSH root | `mysql-cluster-community-data-node` |
| 3 VM3 | Vérifier paquets Cluster VM3 | `dpkg -l` | VM3 démarrée, SSH root | `mysql-cluster-community-server`, `mysql-cluster-client` |
| 4 VM1 | Installer paquets Cluster VM1 | `apt-get update` ; `apt-get install -y mysql-cluster-community-management-server mysql-cluster-community-data-node mysql-cluster-community-server mysql-cluster-client` | dépôt MySQL valide + clé GPG, root | 4 paquets installés, version 8.0.50-1ubuntu24.04 |
| 4 VM2 | Installer paquets Cluster VM2 | `apt-get update` ; `apt-get install -y mysql-cluster-community-data-node` | dépôt valide, root | data-node installé |
| 4 VM3 | Installer paquets Cluster VM3 | `apt-get update` ; `apt-get install -y mysql-cluster-community-server mysql-cluster-client` | dépôt valide, root | server + client installés |
| (variante dépôt APT) | Ajouter dépôt MySQL APT | `wget https://dev.mysql.com/get/mysql-apt-config_0.8.33-1_all.deb` ; `sudo dpkg -i mysql-apt-config_0.8.33-1_all.deb` ; `apt-get update` | accès Internet | dépôt `repo.mysql.com` ajouté, clé GPG importée |
| 5 VM1 | Rédiger config.ini | `cat > /tmp/config.ini << 'EOF' ... [ndb_mgmd] NodeId=1 HostName=192.168.56.10 ... [ndbd] NodeId=2/3 HostName=192.168.56.11 DataDir=.../ndb_2 /ndb_3 ... [mysqld] NodeId=4/5 HostName=192.168.56.10/12 ... EOF` ; `cp /tmp/config.ini /var/lib/mysql-cluster/config.ini` ; `cat /var/lib/mysql-cluster/config.ini` | `/var/lib/mysql-cluster` existant, paquet management-server installé | config.ini avec NoOfReplicas=2, 5 nodes |
| 6 VM2 | Créer répertoires stockage | `mkdir -p /var/lib/mysql-cluster/ndb_2 /var/lib/mysql-cluster/ndb_3` ; `ls -la /var/lib/mysql-cluster/` | `/var/lib/mysql-cluster` existant, root | répertoires ndb_2, ndb_3 créés |
| 7 VM1 | Démarrer ndb_mgmd | `ndb_mgmd --config-file=/var/lib/mysql-cluster/config.ini --initial` | config.ini valide, port 1186 libre | `MySQL Cluster Management Server mysql-8.0.50 ndb-8.0.50` (+ WARNING IndexMemory déprécié) |
| 8 VM2 | Démarrer ndbmtd NodeId 2 | `cd /var/lib/mysql-cluster/ndb_2` ; `nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial &` | ndb_mgmd démarré, répertoire ndb_2 | `nohup.out`, PID |
| 8 VM2 | Démarrer ndbmtd NodeId 3 | `cd /var/lib/mysql-cluster/ndb_3` ; `nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial &` | NodeId 2 lancé | `nohup.out`, PID |
| 9 VM1 | Démarrer mysqld NodeId 4 | `nohup mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize &` | stockage démarré, datadir MySQL initialisé | `nohup.out`, PID |
| 9 VM3 | Démarrer mysqld NodeId 5 | `nohup mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize &` | stockage démarré, datadir initialisé | `nohup.out`, PID |
| 10 VM1 | Vérifier intégrité cluster | `sleep 5` ; `ndb_mgm -e "SHOW"` | tous nodes démarrés | 5 nodes connectés (1 mgmd, 2 ndbd, 2 mysqld) sans `not connected` |
| 11 VM1 | Config effective | `ndb_config --query-all` | Étape 10 OK | NoOfReplicas=2, DataMemory=256M, IndexMemory=128M, HostName par node |
| 12 VM1 | Test résilience arrêt NodeId 2 | `ndb_mgm -e "2 STOP"` ; `sleep 5` ; `echo '=== Etat apres arret NodeId 2 ==='` ; `ndb_mgm -e "SHOW"` | cluster sain, 5 nodes connectés | Node 2 `not connected`, Node 3 `*` connecté, SQL opérationnels |
| 13 VM2/VM1 | Redémarrer NodeId 2 + resync | `cd /var/lib/mysql-cluster/ndb_2` ; `nohup ndbmtd --ndb-connectstring=192.168.56.10 &` ; `sleep 8` ; `ndb_mgm -e "SHOW"` | NodeId 2 arrêté, répertoire ndb_2 présent, NodeId 3 connecté | NodeId 2 connecté (sans starting/not connected), redondance restaurée |

Fichiers de config : `/var/lib/mysql-cluster/config.ini` (VM1).
Preuves : aucune path `preuves/` explicite.

---

### CHAPITRE 2 — Architecture et Administration

#### Lab-03 — Architecture NDB, nœuds, partitionnement et réplication

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | Lister les nœuds | `ndb_mgm -e 'SHOW'` | cluster démarré, 5 nodes connectés, ndb_mgm installé | 1 ndb_mgmd, 2 ndbd, 2 mysqld, aucun `not connected` |
| 2 VM1 | Config effective | `ndb_config --query-all` | Étape 1 OK, ndb_config installé | NoOfReplicas=2, DataMemory, IndexMemory, HostName par node |
| 3 VM1 | Usage mémoire | `ndb_mgm -e 'ALL REPORT MEMORYUSAGE'` | nodes de stockage démarrés | Data usage 0%, Index usage 0% par node (cluster vide) |
| 4 VM1 | État moteur NDB côté SQL | `mysql -u root -e 'SHOW ENGINE NDB STATUS\G'` | mysqld --ndbcluster, client mysql, accès root SQL | `cluster_node_id=4, connected_host=192.168.56.10…`, nombre de data nodes = 2 |

Fichiers : aucun créé.
Preuves : aucune path `preuves/` explicite.

#### Lab-04 — Quorum, split-brain, node groups et résilience

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | État nominal + node group | `ndb_mgm -e 'SHOW'` | cluster démarré, 5 nodes connectés | Nodegroup: 0 avec nodes 2 et 3, `*` sur node 3 |
| 2 VM1 | Arrêt NodeId 2 | `ndb_mgm -e '2 STOP'` | nodes 2 et 3 connectés | `Node 2: Node shutdown initiated` |
| 2 VM1 | attente | `sleep 5` | — | vide, rc=0 |
| 2 VM1 | séparateur | `echo '=== Etat apres arret ==='` | — | `=== Etat apres arret ===` |
| 2 VM1 | SHOW après arrêt | `ndb_mgm -e 'SHOW'` | — | id=2 `not connected`, id=3 `*` connecté, SQL opérationnels |
| 3 VM2 | cd répertoire node 2 | `cd /var/lib/mysql-cluster/ndb_2` | NodeId 2 arrêté, répertoire ndb_2 présent | vide, rc=0 |
| 3 VM2 | Redémarrer NodeId 2 | `nohup ndbmtd --ndb-connectstring=192.168.56.10 &` | — | `nohup.out`, PID |
| 3 VM2 | attente resync | `sleep 6` | — | vide, rc=0 |
| 4 VM1 | attente + SHOW final | `sleep 8` ; `ndb_mgm -e 'SHOW'` | NodeId 2 redémarré | NodeId 2 connecté, état nominal restauré (5 nodes) |

Fichiers : aucun créé.
Preuves : aucune path `preuves/` explicite.

#### Lab-05 — Configuration détaillée des nœuds, ajout/suppression et surveillance

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | Sauvegarder config.ini | `cp /var/lib/mysql-cluster/config.ini /var/lib/mysql-cluster/config.ini.save` | config.ini présent | vide, rc=0 |
| 1 VM1 | Inspecter config.ini | `cat /var/lib/mysql-cluster/config.ini` | — | contenu config.ini (5 nodes, NoOfReplicas=2) |
| 2 VM2 | Créer répertoire NodeId 6 | `mkdir -p /var/lib/mysql-cluster/ndb_6` ; `ls -la /var/lib/mysql-cluster/` | espace disque VM2 | répertoire ndb_6 créé, listé |
| 2b VM1 | Sauvegarde avant modif | `cp /var/lib/mysql-cluster/config.ini /var/lib/mysql-cluster/config.ini.pre-node6` | sauvegarde étape 1, répertoire ndb_6 | vide, rc=0 |
| 2b VM1 | Déclarer NodeId 6 | `cat >> /var/lib/mysql-cluster/config.ini << 'EOF' ... [ndbd] NodeId=6 HostName=192.168.56.11 DataDir=/var/lib/mysql-cluster/ndb_6 EOF` ; `grep -A3 'NodeId = 6' /var/lib/mysql-cluster/config.ini` | sauvegarde + répertoire ndb_6 | section NodeId 6 ajoutée |
| 2b-bis VM1 | Arrêter gestionnaire | `pkill -x ndb_mgmd` | config.ini modifié, ndb_mgmd running | vide, rc=0 |
| 2b-bis VM1 | Redémarrer gestionnaire | `ndb_mgmd -f /var/lib/mysql-cluster/config.ini` ; `sleep 5` ; `ndb_mgm -e 'SHOW'` | — | `WARNING: --ndb-connectstring is ignored...`, NodeId 6 `not connected` (pas encore démarré) |
| 2c VM2 | Démarrer NodeId 6 | `nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_6.log &` ; `sleep 6` | config.ini modifié, répertoire ndb_6, ndbmtd installé | `ndbmtd_6.log`, PID |
| 2d VM1 | Vérifier NodeId 6 | `ndb_mgm -e 'SHOW'` | NodeId 6 lancé | 3 nodes de stockage (2,3 nodegroup 0 ; 6 nodegroup 1), 6 nodes total |
| 3 VM1 | Surveiller état + mémoire | `ndb_mgm -e 'SHOW'` ; `echo '---'` ; `ndb_mgm -e 'ALL REPORT MEMORYUSAGE'` | cluster démarré | 6 nodes connectés, usage mémoire 0% |
| 4 VM2 | Supprimer NodeId 6 — lister processus | `pgrep -a ndbmtd` | NodeId 6 connecté, sauvegarde config.ini.pre-node6 | liste processus ndbmtd |
| 4 VM1 | Restaurer config.ini | `cp config.ini.pre-node6 config.ini` | — | vide, rc=0 |
| 4 VM1 | Redémarrer gestionnaire | `pkill -x ndb_mgmd && sleep 2 && ndb_mgmd -f /var/lib/mysql-cluster/config.ini` ; `sleep 5` ; `ndb_mgm -e 'SHOW'` | — | `MySQL Cluster Management Server...`, retour à 5 nodes (NodeId 6 disparu) |

Fichiers : `/var/lib/mysql-cluster/config.ini.save`, `config.ini.pre-node6`, `ndbmtd_6.log`, répertoire `/var/lib/mysql-cluster/ndb_6`.
Preuves : aucune path `preuves/` explicite.

#### Lab-06 — Test de panne, redémarrage rolling et maintenance à chaud

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | Arrêter NodeId 2 | `ndb_mgm -e '2 STOP'` | cluster sain, 5 nodes connectés | `Node 2: Node shutdown initiated` |
| 1 VM1 | attente détection | `sleep 3` | — | vide, rc=0 |
| 1 VM1 | SHOW pendant panne | `ndb_mgm -e 'SHOW'` | — | id=2 `not connected`, id=3 `*` connecté |
| 2 VM1 | Arrêter mysqld NodeId 4 | `pkill -x mysqld` | NodeId 5 (VM3) actif pour relais | vide, rc=0 |
| 2 VM1 | attente arrêt | `sleep 3` | — | vide, rc=0 |
| 2 VM1 | vérifier arrêt | `pgrep -a mysqld` | — | aucune ligne (rc=1) |
| 2 VM1 | Redémarrer mysqld NodeId 4 | `nohup mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize &` ; `sleep 5` ; `pgrep -a mysqld` | second SQL NodeId 5 actif | `[PID] mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize` |
| 3 VM1 | État final | `ndb_mgm -e 'SHOW'` | redémarrages faits | 5 nodes connectés sans `not connected` |

Fichiers : `nohup.out`.
Preuves : aucune path `preuves/` explicite.

---

### CHAPITRE 3 — Supervision et Maintenance

#### Lab-07 — Outils de supervision, alertes ndb_mgm et surveillance

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | Lister nœuds + détection anomalie | `ndb_mgm -e 'SHOW'` | cluster démarré, 5 nodes connectés | 5 nodes connectés |
| 2 VM1 | Usage mémoire | `ndb_mgm -e 'ALL REPORT MEMORYUSAGE'` | nodes de stockage démarrés | Data/Index usage 0% par node |
| 3 VM1 | Créer table NDB | `mysql -u root -e "CREATE DATABASE IF NOT EXISTS labndb; CREATE TABLE IF NOT EXISTS labndb.t_ndb_desc (id INT PRIMARY KEY, val VARCHAR(100)) ENGINE=NDB"` | ndb_desc installé, nœud SQL connecté | `Query OK, 0 rows affected` |
| 3 VM1 | Décrire table | `mysql -u root -e "DESCRIBE labndb.t_ndb_desc"` | table créée | structure SQL (id, val) |
| 4 VM1 | Arrêter NodeId 2 (alerte) | `ndb_mgm -e '2 STOP'` | nodes 2 et 3 connectés | `Node 2: Node shutdown initiated` |
| 4 VM1 | attente | `sleep 4` | — | vide, rc=0 |
| 4 VM1 | SHOW alerte | `ndb_mgm -e 'SHOW'` | — | id=2 `not connected`, id=3 `*` connecté |
| 4 VM2 | cd node 2 | `cd /var/lib/mysql-cluster/ndb_2` | — | vide, rc=0 |
| 4 VM2 | Redémarrer NodeId 2 | `nohup ndbmtd --ndb-connectstring=192.168.56.10 &` | — | vide, rc=0 |
| 4 VM2 | attente | `sleep 6` | — | vide, rc=0 |
| 4 VM1 | SHOW retour nominal | `ndb_mgm -e 'SHOW'` | — | id=2 et id=3 connectés |

Fichiers : aucun créé.
Preuves : aucune path `preuves/` explicite.

#### Lab-08 — Sauvegarde START BACKUP, restauration ndb_restore et remplacement de nœud

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | Déclencher sauvegarde | `ndb_mgm -e 'START BACKUP'` ; `sleep 5` | cluster démarré, 5 nodes connectés, espace disque | `Waiting for completed…`, `Backup 1 started from node 1 completed`, StartGCP/StopGCP, #Records, Data/Log |
| 2 VM2 | Lister fichiers sauvegarde | `ls -la BACKUP/` ; `ls -la BACKUP/BACKUP-1/` ; `ls -la ndb_2/BACKUP ndb_3/BACKUP` | sauvegarde faite, répertoire BACKUP | fichiers `.Data`, `.log`, `.ctl` (BACKUP-1.0.2 / .0.3) |
| 3 VM1 | Restaurer schéma | `ndb_restore -c 192.168.56.10 -b 1 --restore_meta --nodeid=2 --backup-path=/var/lib/mysql-cluster/ndb_2/BACKUP/BACKUP-1` | sauvegarde dispo, ndb_restore installé, cluster démarré | `Connected to management server at: 192.168.56.10:1186`, `NDBT_ProgramExit: 0` |
| 4 VM1 | Restaurer données NodeId 2 | `ndb_restore -c 192.168.56.10 -b 1 -r --nodeid=2 --backup-path=/var/lib/mysql-cluster/ndb_2/BACKUP/BACKUP-1` | schéma restauré, sauvegardes dispo | `Running in -r mode`, `NDBT_ProgramExit: 0` |
| 4b VM1 | Restaurer données NodeId 3 | `ndb_restore -c 192.168.56.10 -b 1 -r --nodeid=3 --backup-path=/var/lib/mysql-cluster/ndb_3/BACKUP/BACKUP-1` | étape 4 faite | `NDBT_ProgramExit: 0` |
| 5 VM1/VM2 | Simuler panne NodeId 2 | `ndb_mgm -e '2 STOP'` ; `sleep 5` ; `ndb_mgm -e 'SHOW'` | cluster sain, répertoire ndb_6 préparé | id=2 `not connected`, id=3 `*` connecté |
| 6 VM1 | Déclarer NodeId 6 | `cp config.ini config.ini.pre-node6` ; `cat >> config.ini << 'EOF' ... [ndbd] NodeId=6 … EOF` | NodeId 2 arrêté, répertoire ndb_6 présent, sauvegarde config.ini | section NodeId 6 ajoutée |
| 7 VM1 | Arrêter gestionnaire | `pkill -x ndb_mgmd` | config.ini mis à jour, gestionnaire running | vide |
| 8 VM1 | Redémarrer gestionnaire | `ndb_mgmd --config-file=/var/lib/mysql-cluster/config.ini --initial` | gestionnaire arrêté | `MySQL Cluster Management Server mysql-8.0.50 ndb-8.0.50` |
| 9 VM2 | Lancer NodeId 6 remplacement | `nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_6.log &` ; `sleep 8` | config.ini mis à jour, gestionnaire redémarré, répertoire ndb_6 | `ndbmtd_6.log` |
| 10 VM2 | Lister processus | `pgrep -a ndbmtd` | NodeId 6 lancé | 4 lignes ndbmtd (2,3,6 + résidus) |
| 11 VM1 | Vérifier état après remplacement | `ndb_mgm -e 'SHOW'` | NodeId 6 lancé | id=2 `not connected`, id=3 `*`, id=6 `Nodegroup: 1` connecté |

Fichiers : `config.ini.pre-node6`, `ndbmtd_6.log`, répertoires BACKUP (`ndb_2/BACKUP/BACKUP-1`, `ndb_3/BACKUP/BACKUP-1`).
Preuves : aucune path `preuves/` explicite.

#### Lab-09 — MySQL Cluster Manager (MCM) — THÉORIQUE UNIQUEMENT

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | Constat absence paquet MCM | `dpkg -l | grep -i 'mysql-cluster-manager' || echo 'paquet mysql-cluster-manager non installé'` | aucun paquet MCM attendu | `paquet mysql-cluster-manager non installé` |
| 2 VM1 | Constat absence binaires | `which mcm mcmd || echo 'binaires mcm absents'` | étape 1 | `binaires mcm absents` |
| 3 VM1 | Démonstration théorique | `echo 'Demonstration theorique MCM : aucune commande mcm/mcmd n est executee sur cette infrastructure'` | étapes 1 et 2 | constat théorique, aucune commande mcm/mcmd exécutée |

Note cours : opérations NDB-20/21/22 présentées à titre théorique uniquement (produit commercial Oracle, binaires absents, pas d'accès Internet). **Lab hors périmètre exécutable.**

Fichiers : aucun créé.
Preuves : aucune path `preuves/` explicite.

---

### CHAPITRE 4 — Optimisation, performances, réplication inter-clusters

#### Lab-10 — Paramètres performance et goulots d'étranglement

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | Usage mémoire stockage | `ndb_mgm -e 'ALL REPORT MEMORYUSAGE'` | cluster démarré, ndb_mgm opérationnel | Data/Index usage 0% (cluster vide) |
| 2 VM1 | RAM | `free -m` | outils free/df disponibles | Mem total ~1011 Mo, Swap ~1023 Mo |
| 2b VM1 | Disque VM1 | `df -h /var/lib/mysql-cluster` | df disponible VM1 | `/dev/sda1 15G 3,0G 12G 21%` |
| 2c VM2 | Disque VM2 | `df -h /var/lib/mysql-cluster` | df disponible VM2 | idem |
| 2d VM3 | Disque VM3 | `df -h /` | df disponible VM3 | `/dev/sda1 15G 3,0G 12G 21% /` |
| 3 VM1 | Sauvegarde config.ini | `cp config.ini config.ini.bak.optim` | sauvegarde config.ini (Lab-05) | vide, rc=0 |
| 3b VM1 | Modifier DataMemory/IndexMemory | `grep -E '^DataMemory = ' config.ini && sed -i 's/^DataMemory = .*/DataMemory = 512M/; s/^IndexMemory = .*/IndexMemory = 256M/' config.ini` | sauvegarde faite | vide, rc=0 |
| 3c VM1 | Vérifier valeurs | `grep -E 'DataMemory|IndexMemory|NoOfReplicas' config.ini` | config.ini modifié | `NoOfReplicas = 2`, `DataMemory = 512M`, `IndexMemory = 256M` |
| 4 VM2 | Arrêter ndbmtd | `pkill -x ndbmtd` | config.ini modifié, répertoires ndb_2/ndb_3 | vide, rc=0 |
| 4b VM2 | Redémarrer NodeId 2 | `nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_2.log &` | processus arrêtés | vide, rc=0 |
| 4c VM2 | Redémarrer NodeId 3 | `nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_3.log &` | NodeId 2 redémarré | vide, rc=0 |
| 4d VM2 | attente | `sleep 5` | — | vide, rc=0 |
| 4e VM2 | Lister processus | `pgrep -a ndbmtd` | nodes redémarrés | 4 lignes ndbmtd |
| 5 VM1 | SHOW | `ndb_mgm -e 'SHOW'` | nodes redémarrés | 5 nodes connectés |
| 5b VM1 | Config effective | `ndb_config --query-all` | nodes redémarrés | DataMemory=512M, IndexMemory=256M, NoOfReplicas=2 |

Fichiers : `config.ini.bak.optim`, `ndbmtd_2.log`, `ndbmtd_3.log`.
Preuves : aucune path `preuves/` explicite.

#### Lab-11 — Sharding, partitionnement et gros volumes

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | Créer base | `mysql -u root -e "CREATE DATABASE IF NOT EXISTS labperf"` | mysqld --ndbcluster, datadir accessible | `Query OK, 1 row affected` |
| 1 VM1 | Créer table NDB | `mysql -u root -e "CREATE TABLE IF NOT EXISTS labperf.t_shard (id INT PRIMARY KEY, val VARCHAR(100)) ENGINE=NDB"` | base créée | `Query OK, 0 rows affected` |
| 1 VM1 | Insérer données | `mysql -u root -e "INSERT INTO labperf.t_shard (id,val) VALUES (1,'a'),(2,'b'),(3,'c'),(4,'d'),(5,'e') ON DUPLICATE KEY UPDATE val=VALUES(val)"` | table créée | `Query OK, 5 rows affected` |
| 1 VM1 | Vérifier | `mysql -u root -e "SELECT COUNT(*) FROM labperf.t_shard"` | — | `COUNT(*) = 5` |
| 2 VM1 | Décrire table | `mysql -u root -e "DESCRIBE labperf.t_shard"` | table créée, ndb_desc dispo (non utilisé) | structure SQL (id, val) |
| 3 VM1 | Goulots mémoire | `ndb_mgm -e 'ALL REPORT MEMORYUSAGE'` | cluster démarré | Data/Index usage 0% |
| 3b VM1 | Config stockage | `ndb_config --query-all` | cluster démarré | DataMemory=512M, IndexMemory=256M, NoOfFragmentLogParts=4, RedoBuffer=32M |
| 4 VM2 | Créer répertoires futurs nodes | `mkdir -p /var/lib/mysql-cluster/ndb_7 /var/lib/mysql-cluster/ndb_8` | espace disque VM2, ndbmtd installé | répertoires ndb_7, ndb_8 créés |
| 4b VM2 | Vérifier répertoires | `ls -ld /var/lib/mysql-cluster/ndb_7 /var/lib/mysql-cluster/ndb_8` | répertoires créés | `drwxr-xr-x … ndb_7 ndb_8` |

Fichiers : aucun créé (préparation ndb_7/ndb_8 uniquement).
Preuves : aucune path `preuves/` explicite.
Note cours : démarrage effectif des nodes 7/8 non réalisé (préparation uniquement).

#### Lab-12 — Réplication entre clusters (référence/démonstration) — NON EXÉCUTABLE

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | Santé cluster principal | `ndb_mgm -e 'SHOW'` | Cluster A démarré, ndb_mgm opérationnel | 5 nodes connectés (gestion 1, stockage 2/3, SQL 4/5) |
| 2 VM1 | Activer journal binaire | `mysql -u root -e "SHOW VARIABLES LIKE 'log_bin'"` ; `printf '[mysqld]\nlog_bin = mysql-bin\nserver-id = 1\n' >> /etc/mysql/mysql.conf.d/replication.cnf && systemctl restart mysql` ; `mysql -u root -e "SHOW VARIABLES LIKE 'server_id'"` | mysqld Id=4 accessible | `log_bin = OFF` (avant) ; `server_id = 1` (après, illustratif) |
| 3 VM1 | Utilisateur réplication + position | `mysql -u root -e "CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'repl_pass'"` ; `mysql -u root -e "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%'"` ; `mysql -u root -e "SHOW MASTER STATUS\G"` | journal binaire activé | `Query OK` ; `File: mysql-bin.000001, Position: 154` |
| 4 VM3 | Déployer Cluster B — THÉORIQUE | `mkdir -p /var/lib/mysql-cluster/clusterB` ; `cat > /var/lib/mysql-cluster/clusterB/config.ini << 'EOF' … [ndb_mgmd] NodeId=10 PortNumber=1188 … [ndbd] NodeId=20/21 … [mysqld] NodeId=6 … EOF` ; `ndb_mgmd --ndb-nodeid=10 --initial --config-file=…/clusterB/config.ini --configdir=…/clusterB > mgmdB.log &` ; `sleep 2` ; `ndbmtd --ndb-nodeid=20 --ndb-connectstring=192.168.56.12:1188 --initial > ndbmtdB.log &` ; `ndbmtd --ndb-nodeid=21 … --initial > ndbmtdB_21.log &` ; `sleep 3` ; `pgrep -a 'ndb_mgmd|ndbmtd'` ; `nohup mysqld --ndbcluster --ndb-connectstring=192.168.56.12:1188 --port=3307 --user=mysql --daemonize > /tmp/mysqld-6.log &` | VM3 (héberge déjà SQL NodeId 5 du Cluster A) — **non réalisable en pratique** | (illustratif uniquement, non exécuté) |
| 5 VM3 | Canal réplication replica | `mysql -u root --protocol=TCP -h 127.0.0.1 -P 3307 -e "CHANGE MASTER TO MASTER_HOST='192.168.56.10', MASTER_USER='repl', MASTER_PASSWORD='repl_pass', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=154"` ; `… -e "START SLAVE"` ; `… -e "SHOW SLAVE STATUS\G"` | Cluster B démarré, position binaire relevée | `Query OK` ; `ERROR 2003 … Connection refused` (port 3307 non ouvert — théorique) |
| 6 VM1/VM3 | Insérer + vérifier propagation | `mysql -u root -e "CREATE DATABASE IF NOT EXISTS labrep"` ; `CREATE TABLE … ENGINE=NDB` ; `INSERT …` ; `SELECT * FROM labrep.t_repl` ; sur VM3 `CREATE TABLE …` ; `SELECT * FROM labrep.t_repl` | canal réplication actif | `101 principal / 102 secours` (illustratif) |

Fichiers : `/etc/mysql/mysql.conf.d/replication.cnf`, `/var/lib/mysql-cluster/clusterB/config.ini`, `mgmdB.log`, `ndbmtdB.log`, `ndbmtdB_21.log`, `/tmp/mysqld-6.log`.
Preuves : aucune path `preuves/` explicite.
**Lab hors périmètre exécutable** (voir section 3).

#### Lab-13 — Simulation de panne, failover et failback

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | État initial | `ndb_mgm -e 'SHOW'` | cluster démarré et sain | 5 nodes connectés |
| 1b VM1 | Créer table de test | `mysql -u root -e "CREATE DATABASE IF NOT EXISTS labfail"` ; `CREATE TABLE IF NOT EXISTS labfail.t_fail (id INT PRIMARY KEY, val VARCHAR(100)) ENGINE=NDB` ; `INSERT INTO labfail.t_fail (id,val) VALUES (101,'principal'),(102,'secours') ON DUPLICATE KEY UPDATE val=VALUES(val)` | mysqld Id=4 accessible | `Query OK` |
| 2 VM1 | Panne NodeId 2 | `ndb_mgm -e "2 STOP"` | NodeId 2 connecté | `Node 2: Node shutdown initiated` |
| 3 VM1 | Observer failover | `ndb_mgm -e 'SHOW'` | NodeId 2 arrêté | id=2 `not connected`, id=3 connecté |
| 4 VM1 | Continuité de service | `mysql -u root -e "SELECT COUNT(*) FROM labfail.t_fail;"` | NodeId 2 en panne, Id=3 dispo | `COUNT(*) = 2` |
| 5 VM2 | Redémarrer NodeId 2 (failback) | `nohup ndbmtd --ndb-connectstring=192.168.56.10 &` ; `sleep 5` | NodeId 2 arrêté, répertoire ndb_2 présent | vide, rc=0 |
| 5c VM1 | État après redémarrage | `ndb_mgm -e 'SHOW'` | NodeId 2 relancé | id=2 `recovering` puis `connected` |
| 6 VM1 | Vérifier resync + données | `ndb_mgm -e 'SHOW'` ; `mysql -u root -e "SELECT COUNT(*) FROM labfail.t_fail"` ; `mysql -u root -e "SELECT * FROM labfail.t_fail ORDER BY id"` | NodeId 2 connecté | 5 nodes connectés, `COUNT(*) = 2`, lignes 101/102 |

Fichiers : aucun créé.
Preuves : aucune path `preuves/` explicite.

---

### CHAPITRE 5 — Sécuriser MySQL Cluster

#### Lab-14 — Sécuriser MySQL Cluster : TLS, comptes SQL, sauvegardes, isolement

| Étape | But | Commande exacte | Prérequis | Résultat attendu |
|---|---|---|---|---|
| 1 VM1 | Sauvegarder config.ini | `cp config.ini config.ini.bak.tls` | config.ini présent et valide | vide, rc=0 |
| 1b VM1 | Ajouter TLS config.ini | `cat >> config.ini << 'EOF' … [tcp default] TLS=1 … [ndb_mgmd default] TLS=1 TLSCAFile=/etc/mysql-cluster-tls/ca-cert.pem TLSCertificateFile=…/mgmd-cert.pem TLSKeyFile=…/mgmd-key.pem [ndbd default] … [mysqld default] … EOF` | sauvegarde étape 1 | lignes TLS ajoutées |
| 1c VM1 | Vérifier TLS | `grep -E 'TLS|TLSCAFile|TLSCertificateFile|TLSKeyFile' config.ini` | config.ini modifié | lignes TLS listées |
| 2 VM1 | Créer répertoire TLS | `mkdir -p /etc/mysql-cluster-tls` | openssl installé, répertoire créable | vide, rc=0 |
| 2b VM1 | Générer CA | `openssl req -x509 -newkey rsa:2048 -keyout ca-key.pem -out ca-cert.pem -days 365 -nodes -subj '/CN=MySQLCluster-CA/L=Lab/O=Formation'` | openssl, répertoire TLS | vide, rc=0 |
| 2c VM1 | Clé+CSR ndb_mgmd | `openssl req -newkey rsa:2048 -keyout mgmd-key.pem -out mgmd-req.pem -nodes -subj '/CN=ndb_mgmd/L=Lab/O=Formation'` | CA générée | vide, rc=0 |
| 2d VM1 | Signer cert ndb_mgmd | `openssl x509 -req -in mgmd-req.pem -CA ca-cert.pem -CAkey ca-key.pem -out mgmd-cert.pem -days 365 -set_serial 01` | CSR + CA | vide, rc=0 |
| 2d-bis VM1 | Cert ndbd | `openssl req -newkey rsa:2048 -keyout ndbd-key.pem -out ndbd-req.pem -nodes -subj '/CN=ndbd/L=Lab/O=Formation'` ; `openssl x509 -req -in ndbd-req.pem -CA ca-cert.pem -CAkey ca-key.pem -out ndbd-cert.pem -days 365 -set_serial 02` | CA | vide, rc=0 |
| 2d-ter VM1 | Cert mysqld | `openssl req -newkey rsa:2048 -keyout mysqld-key.pem -out mysqld-req.pem -nodes -subj '/CN=mysqld/L=Lab/O=Formation'` ; `openssl x509 -req -in mysqld-req.pem -CA ca-cert.pem -CAkey ca-key.pem -out mysqld-cert.pem -days 365 -set_serial 03` | CA | vide, rc=0 |
| 2e VM1 | Protéger clés privées | `chmod 600 ca-key.pem mgmd-key.pem ndbd-key.pem mysqld-key.pem` | certs générés | vide, rc=0 |
| 2f VM1 | Lister fichiers TLS | `ls -la ca-cert.pem ca-key.pem mgmd-cert.pem mgmd-key.pem` | clés protégées | `-rw-r--r--` certs, `-rw-------` clés |
| 2g VM1/2/3 | Copier certs VM2 et VM3 | `scp ca-cert.pem ca-key.pem mgmd-cert.pem mgmd-key.pem ndbd-cert.pem ndbd-key.pem mysqld-cert.pem mysqld-key.pem root@192.168.56.11:/etc/mysql-cluster-tls/` ; `scp … root@192.168.56.12:/etc/mysql-cluster-tls/` | certs générés VM1, répertoire TLS sur VM2/3 | 100% transfert, rc=0 |
| 3 VM1/2/3 | Arrêter cluster | `pkill -x mysqld` (VM1 puis VM3) ; `pgrep -a ndbmtd` ; `kill <PID_ndbmtd_2> <PID_ndbmtd_3>` (VM2) ; `pkill -x ndb_mgmd` (VM1) | config.ini TLS, certs sur nodes | vide, rc=0 |
| 3a VM1 | Redémarrer gestionnaire TLS | `ndb_mgmd --config-file=/var/lib/mysql-cluster/config.ini` ; `cd /var/lib/mysql-cluster/ndb_2` (VM2) | cluster arrêté | `MySQL Cluster Management Server … [MgmtSrvr] INFO -- TLS enabled…` (illustratif) |
| 3b VM2 | Lancer NodeId 2 TLS | `nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_2.log &` | répertoire ndb_2 | vide, rc=0 |
| 3c VM2 | Lancer NodeId 3 TLS | `nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_3.log &` | NodeId 2 lancé | vide, rc=0 |
| 3d VM2 | attente | `sleep 5` | — | vide, rc=0 |
| 3e VM1 | Lancer SQL NodeId 4 | `nohup mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize > /tmp/mysqld-4.log &` | stockage lancé, TLS activé | vide, rc=0 |
| 3f VM3 | Lancer SQL NodeId 5 | `nohup mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize > /tmp/mysqld-5.log &` | SQL Id=4 lancé | vide, rc=0 |
| 3g VM3 | attente SQL | `sleep 5` | — | vide, rc=0 |
| 3h VM1 | Vérifier cluster TLS | `ndb_mgm -e "SHOW"` | SQL Id=4 et Id=5 lancés | 5 nodes connectés (illustratif) |
| 4 VM1 | Compte applicatif | `mysql -u root -e "CREATE USER IF NOT EXISTS 'app_user'@'192.168.56.%' IDENTIFIED BY 'LabAppPass123!'"` ; `GRANT SELECT, INSERT, UPDATE, DELETE ON labperf.* TO 'app_user'@'192.168.56.%'` ; `FLUSH PRIVILEGES` ; `SHOW GRANTS FOR 'app_user'@'192.168.56.%'` | mysqld --ndbcluster + TLS, accès root SQL | `Query OK, 0 rows affected` ; grants labperf.* |
| 4 VM1 | Compte sauvegarde | `mysql -u root -e "CREATE USER IF NOT EXISTS 'backup_user'@'192.168.56.%' IDENTIFIED BY 'LabBackupPass123!'"` ; `GRANT SELECT, SHOW VIEW, LOCK TABLES ON *.* TO 'backup_user'@'192.168.56.%'` | — | `Query OK` |
| 5 VM1 | Comptes non sécurisés | `mysql -u root -e "SELECT User, Host FROM mysql.user WHERE User='' OR authentication_string='';"` | mysqld démarré | `Empty set (0.00 sec)` |
| 5b VM1 | Lister comptes | `mysql -u root -e "SELECT User, Host FROM mysql.user;"` | étape 5 | `root@localhost`, `app_user@192.168.56.%`, `backup_user@192.168.56.%` |
| 6 VM1 | Sauvegarde protégée | `ndb_mgm -e "START BACKUP"` ; `sleep 5` | cluster opérationnel | `Waiting for completed…`, `Backup 1 … completed` (illustratif) |
| 6b VM1 | attente sauvegarde | `sleep 5` | sauvegarde lancée | vide, rc=0 |
| 7 VM2 | Protéger répertoires sauvegarde | `chmod 700 ndb_2/BACKUP ndb_3/BACKUP` | sauvegarde terminée | vide, rc=0 |
| 7b VM2 | Vérifier droits sauvegarde | `ls -la ndb_2/BACKUP/BACKUP-1/ ndb_3/BACKUP/BACKUP-1/` | droits restreints | `drwx------`, `-rw-------` |
| 8 VM1 | isolement réseau | `ip route show default` | réseau vboxnet0, NAT présent | `default via 10.0.2.2 dev enp0s3` (ou aucune route) |
| 9 VM1 | interface VM1 | `ip -br addr show enp0s8` | étape 8 | `enp0s8 UP 192.168.56.10/24 …` |
| 10 VM2 | route par défaut VM2 | `ip route show default || echo 'aucune route par défaut'` | — | `aucune route par défaut` |
| 11 VM2 | interface VM2 | `ip -br addr show enp0s8` | — | `enp0s8 UP 192.168.56.11/24 …` |
| 12 VM1 | processus ndb_mgmd | `pgrep -a ndb_mgmd` | cluster démarré | `ndb_mgmd --config-file=… --initial` |
| 13 VM1 | processus mysqld | `pgrep -a mysqld` | étape 12 | `mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize` |
| 14 VM2 | processus ndbmtd | `pgrep -a ndbmtd` | cluster démarré | 2 lignes ndbmtd |
| 15 VM3 | processus mysqld | `pgrep -a mysqld` | cluster démarré | `mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize` |

Fichiers : `config.ini.bak.tls`, `/etc/mysql-cluster-tls/{ca,mgmd,ndbd,mysqld}-{cert,key,req}.pem`, `ndbmtd_2.log`, `ndbmtd_3.log`, `/tmp/mysqld-4.log`, `/tmp/mysqld-5.log`, `/etc/mysql/mysql.conf.d/replication.cnf` (non, c'est Lab-12), répertoires BACKUP protégés.
Preuves : aucune path `preuves/` explicite.

---

## 2. ANALYSE DE COMPATIBILITÉ UBUNTU 24.04 LTS PAR COMMANDE

Légende : ✅ Compatible / ⚠️ Risque / ❌ Incompatible

| Commande / contexte | Labs | Verdict | Raison |
|---|---|---|---|
| `hostnamectl set-hostname <nom>` | Lab-01 é6 | ✅ | Disponible sur Ubuntu 24.04 (systemd). |
| `tee /etc/netplan/01-netcfg.yaml` + interface `enp0s8` | Lab-01 é6 | ⚠️ Risque | netplan existe sur Ubuntu 24.04. MAIS l'interface host-only est généralement `enp0s3` quand c'est l'adaptateur 1, et `enp0s8` quand c'est l'adaptateur 2. Le cours déclare adaptateur 1 = host-only vboxnet0 et adaptateur 2 = NAT, ce qui fait de l'host-only la **première** interface → très probablement `enp0s3`, pas `enp0s8`. Le netplan ciblant `enp0s8` ne s'appliquerait à rien et l'IP statique ne serait pas configurée. À corriger : détecter l'interface (`ip -br link show`) ou utiliser `match: {macaddress: …}` / `set-name: enp0s8`. |
| `netplan apply` | Lab-01 é6 | ✅ | Disponible sur Ubuntu 24.04. |
| `systemctl enable --now ssh` | Lab-01 é6 | ✅ | Le service s'appelle bien `ssh` sur Ubuntu (pas `sshd`). |
| `ip -br addr show enp0s8` | Lab-01 é7, Lab-14 é9/11 | ⚠️ Risque | Même souci que netplan : si l'interface s'appelle `enp0s3`, la commande échoue (no such device). |
| `ping -c 4 <ip>` | Lab-01 é7 | ✅ | iputils-ping présent par défaut sur Ubuntu Server 24.04. |
| `VBoxManage snapshot <vm> list` | Lab-01 é8 (hôte) | ✅ | Commande hôte (VirtualBox), indépendante de l'OS invité. |
| `rm -rf /var/lib/mysql-cluster …` | Lab-01 é1 | ✅ | Opération filesystem standard. |
| `apt-get purge -y mysql-cluster-* … || true` | Lab-01 é1b | ✅ | apt disponible ; `|| true` gère l'absence de paquets. |
| `apt-get autoremove -y || true` | Lab-01 é1c | ✅ | idem. |
| `dpkg -l` / `dpkg -l | grep …` | Lab-02 é1-3, Lab-09 é1 | ✅ | dpkg disponible. |
| `apt-get update` | Lab-02 é4 | ⚠️ Risque | Nécessite un dépôt valide + accès réseau (NAT). Le lab dit "pas d'accès Internet permanent sur les nœuds" mais appelle `apt-get update`. Contre-dit. De plus la clé GPG MySQL est expirée (EXPKEYSIG B7B3B788A8D3785C) → `apt-get update` échoue sur le dépôt repo.mysql.com sans réimport de clé. |
| `apt-get install -y mysql-cluster-community-*` | Lab-02 é4 | ⚠️ Risque | Les paquets `mysql-cluster-community-*` n'existent que dans le dépôt MySQL 8.0. Le dépôt MySQL 8.4 LTS (par défaut sur `noble` via mysql-apt-config récent) **ne contient pas NDB** (supprimé à partir de MySQL 8.4). Il faut forcer `mysql-8.0` via `dpkg-reconfigure mysql-apt-config`. Version affichée `8.0.50-1ubuntu24.04` est suspecte (suffixe `ubuntu24.04` non standard pour des paquets MySQL Oracle). |
| `wget https://dev.mysql.com/get/mysql-apt-config_0.8.33-1_all.deb` | Lab-02 dépôt APT | ⚠️ Risque | Nécessite accès Internet (NAT) + version du .deb susceptible d'avoir évolué. |
| `sudo dpkg -i mysql-apt-config_*.deb` | Lab-02 dépôt APT | ⚠️ Risque | Les labs utilisent `root` direct (pas de `sudo`); le cours mélange `sudo` (procédure hôte) et root direct (VMs). Interactif (sélection produit/version) → non automatisable sans preseed. |
| `ndb_mgmd --config-file=… --initial` | Lab-02 é7, Lab-05, Lab-08, Lab-14 | ✅ | Fonctionne sur Ubuntu 24.04. Crée des fichiers dans DataDir (nécessite droits d'écriture sur /var/lib/mysql-cluster). |
| `ndbmtd --ndb-connectstring=… --initial` / sans `--initial` | Lab-02 é8, Lab-04, Lab-05, Lab-06, Lab-08, Lab-10, Lab-13, Lab-14 | ✅ | Fonctionne sur Ubuntu 24.04. `--initial` réinitialise le stockage (destructif hors lab). |
| `mysqld --ndbcluster --ndb-connectstring=… --user=mysql --daemonize &` | Lab-02 é9, Lab-06, Lab-10, Lab-14 | ⚠️ Risque | (1) `--daemonize` met déjà mysqld en arrière-plan ; le `&` est redondant mais inoffensif. (2) Le datadir MySQL doit être initialisé au préalable (`mysqld --initialize` ou `mysqld --initialize-insecure`), sinon le démarrage échoue — le cours ne le mentionne que comme "piège". (3) AppArmor sur Ubuntu 24.04 profile `mysqld` et peut restreindre l'accès à `/var/lib/mysql-cluster` (hors `/var/lib/mysql`) et à `/etc/mysql-cluster-tls` → risque de refus d'accès aux certificats TLS et au DataDir NDB. (4) L'utilisateur système `mysql` doit exister (créé par le paquet mysql-cluster-community-server). |
| `ndb_mgm -e "SHOW"` / `ndb_mgm -e '2 STOP'` / `ndb_mgm -e "START BACKUP"` | tous | ✅ | ndb_mgm fonctionne sur Ubuntu 24.04. Port 1186 doit être libre. |
| `ndb_config --query-all` | Lab-02 é11, Lab-03, Lab-05, Lab-10, Lab-11 | ✅ | Disponible. Sortie volumineuse (CSV-like). |
| `mysql -u root -e "…"` | Lab-03 é4, Lab-07, Lab-12, Lab-13, Lab-14 | ⚠️ Risque | Connexion root MySQL : par défaut sur Ubuntu/mysql-cluster, root s'authentifie via `auth_socket` (unix socket) sans mot de passe, ou nécessite un mot de passe selon l'initialisation. `mysql -u root` depuis un shell root fonctionne généralement via socket. À vérifier après `mysqld --initialize`. |
| `SHOW ENGINE NDB STATUS\G` | Lab-03 é4 | ✅ | Fonctionne si mysqld lancé avec --ndbcluster et connecté au cluster. |
| `mysql -u root -e "CREATE USER …" / GRANT / SHOW GRANTS / FLUSH PRIVILEGES` | Lab-14 é4-5 | ✅ | SQL standard, fonctionne si mysqld running. |
| `ndb_restore -c … -b 1 --restore_meta --nodeid=2 …` | Lab-08 é3 | ⚠️ Risque | `ndb_restore` est un nœud API : il doit pouvoir se déclarer au gestionnaire. config.ini déclare bien des nodes `[mysqld]` (NodeId 4/5) → OK. Doit tourner avec le cluster démarré. `--restore_meta` une seule fois. |
| `ndb_restore -c … -b 1 -r --nodeid=2 …` | Lab-08 é4/4b | ✅ | idem, par node de stockage. |
| `openssl req …` / `openssl x509 …` | Lab-14 é2 | ✅ | `openssl` disponible sur Ubuntu 24.04 (paquet openssl, installé par défaut ou via apt). |
| `scp … root@192.168.56.11:/etc/…` | Lab-14 é2g | ⚠️ Risque | Nécessite que SSH root soit autorisé (`PermitRootLogin yes` dans `/etc/ssh/sshd_config`) et un mot de passe/clé connu. Ubuntu 24.04 désactive `PermitRootLogin` par défaut (ou interdit le mot de passe root). Le cours suppose "accès root sur les trois VM (mot de passe dans .env)" sans montrer la configuration de sshd. Risque d'échec si root login par mot de passe désactivé. |
| `ip route show default` | Lab-14 é8/10 | ✅ | iproute2 présent par défaut sur Ubuntu 24.04. |
| `ip -br addr show enp0s8` | Lab-14 é9/11 | ⚠️ Risque | Même souci d'interface `enp0s3` vs `enp0s8` que netplan. |
| `free -m` | Lab-10 é2 | ✅ | `procps` présent par défaut. |
| `df -h …` | Lab-10 é2b/2c/2d | ✅ | `coreutils` présent par défaut. |
| `sed -i 's/…/…/' config.ini` | Lab-10 é3b | ✅ | GNU sed présent par défaut. |
| `pgrep -a ndbmtd` / `pgrep -a mysqld` / `pgrep -a ndb_mgmd` | Lab-05 é4, Lab-06, Lab-08 é10, Lab-14 é12-15 | ✅ | `procps` présent. `pgrep -a` affiche la ligne de commande complète. |
| `pkill -x ndbmtd` / `pkill -x mysqld` / `pkill -x ndb_mgmd` | Lab-05, Lab-06, Lab-10 é4, Lab-14 é3 | ✅ | Disponible. `pkill -x ndbmtd` arrête **tous** les ndbmtd (nodes 2 et 3 simultanément sur VM2) → interruption du stockage, cohérent avec le cours pour Lab-10 (redémarrage complet) mais dangereux ailleurs. |
| `kill <PID_ndbmtd_2> <PID_ndbmtd_3>` | Lab-14 é3 | ⚠️ Risque | `<PID_…>` est un placeholder non remplacé par une commande réelle : l'apprenant doit identifier les PID manuellement. Pas une commande exécutoire telle quelle. |
| `systemctl restart mysql` | Lab-12 é2 | ❌ Incompatible/incohérent | Le cours lance mysqld manuellement (`nohup … --daemonize &`), pas via un service systemd `mysql`. Il n'y a pas nécessairement de service `mysql` systemd activé. `systemctl restart mysql` peut échouer (unit not found) ou redémarrer une instance InnoDB distincte. De plus Lab-12 est de toute façon théorique. |
| `mysql-apt-config` sélection version 8.0 vs 8.4 | Lab-02 dépôt APT | ❌ Risque bloquant | MySQL Cluster NDB n'existe que dans MySQL 8.0. Sur Ubuntu 24.04 (noble), mysql-apt-config sélectionne par défaut MySQL 8.4-lts qui **ne contient pas** les paquets `mysql-cluster-community-*`. Il faut impérativement reconfigurer pour `mysql-8.0`. Le cours le documente bien dans sa partie "Dépannage", mais la procédure principale é4 suppose les paquets trouvables. |

### Politiques de sécurité Ubuntu 24.04 susceptibles de bloquer
- **AppArmor** : profil `usr.sbin.mysqld` actif par défaut. Peut restreindre l'accès de mysqld aux répertoires hors `/var/lib/mysql`, `/etc/mysql`, `/run/mysqld`. Les DataDir NDB (`/var/lib/mysql-cluster/ndb_2`, `ndb_3`) et les certificats TLS (`/etc/mysql-cluster-tls`) sont hors des chemins habituels → risque de refus (logs dans `/var/log/syslog` ou `auditd`). Solution : profil en mode complain ou ajuste de alias.
- **seccomp** : filtre seccomp de mysqld présent mais généralement compatible avec NDB.
- **SSH root** : `PermitRootLogin` souvent interdit par mot de passe sur Ubuntu 24.04 → `scp root@…` et SSH root peuvent échouer. À configurer (`PermitRootLogin yes` ou clé SSH root).
- **DNS/netplan** : `nameservers: [192.168.56.1]` dans netplan — l'hôte 192.168.56.1 n'est pas un serveur DNS. La résolution des noms de dépôts (archive.ubuntu.com, repo.mysql.com) échouera sans DNS valide → `apt-get update` échoue. À corriger (serveur DNS réel ou suppression de la ligne nameservers).

### Différences résultat attendu vs résultat réel probable
- `dpkg -l` : le cours affiche des paquets `8.0.50-1ubuntu24.04` qui n'existent pas dans les dépôts standards (paquets Oracle MySQL, pas Ubuntu). Résultat réel : paquets introuvables sans dépôt MySQL 8.0 configuré.
- `ndb_mgmd --initial` : le cours affiche un WARNING `IndexMemory is deprecated`. Ce warning apparaît bien sur MySQL 8.0.50.
- `free -m` : le cours affiche Mem total 1011 Mo (1 Go VM) — cohérent.
- `ip route show default` : le cours attend `default via 10.0.2.2 dev enp0s3` (NAT). Cela confirme que l'interface NAT est `enp0s3`, donc l'host-only (adaptateur 1) est probablement aussi `enp0s3`… contradiction avec l'utilisation de `enp0s8` dans le cours. Risque de cohérence.

---

## 3. LABS HORS PÉRIMÈTRE (NON RÉALISABLES SUR 3 VMs ISOLÉES)

| Lab | Justification | Statut dans le cours |
|---|---|---|
| **Lab-09** (MySQL Cluster Manager) | Binaires `mcm`/`mcmd` absents, produit commercial Oracle nécessitant une licence et un dépôt MySQL/Oracle avec accès Internet. Le cours le reconnaît expressément : "non réalisable en pratique", "démonstration commentée, sans exécution réelle". | ✅ Déclaré hors périmètre par le cours (théorique uniquement). |
| **Lab-12** (réplication inter-clusters) | Nécessite un second cluster complet (Cluster B : gestionnaire Id=10 port 1188, 2 nœuds de stockage Id=20/21, nœud SQL replica Id=6 port 3307) sur VM 3, qui héberge déjà le nœud SQL NodeId 5 du Cluster A. Conflits de ports/ressources sur une seule VM de 1 Go RAM. Le cours le reconnaît : "Aucune commande de ce lab n'est executable sur l'infrastructure a 3 VMs", "toutes les sorties presentees sont illustractives (non executees en lab)". | ✅ Déclaré hors périmètre par le cours (référence/démonstration uniquement). |
| Lab-11 étape 4 (préparation nodes 7/8) | Les répertoires `ndb_7`/`ndb_8` sont créés mais le démarrage effectif des nodes 7 et 8 (modification config.ini, redémarrage gestionnaire, lancement ndbmtd) est présenté comme une extension non réalisée ("préparation", "présenté à titre de préparation"). | ⚠️ Partiellement hors périmètre (préparation seulement, pas de test réel des nodes 7/8). |
| Lab-12 étape 2 `systemctl restart mysql` | Même dans le cadre théorique, incohérent avec le lancement manuel de mysqld du cours (pas de service systemd `mysql`). | ⚠️ Incohérent. |

Aucun autre lab n'est marqué hors périmètre. Lab-01 à Lab-08, Lab-10, Lab-11 (partiel) et Lab-13, Lab-14 sont présentés comme exécutables.

---

## 4. CORRECTIONS PROBABLES NÉCESSAIRES AVANT TEST

1. **Netplan / nom d'interface** : Remplacer `enp0s8` par une détection dynamique ou vérifier le nom réel (`ip -br link show`). Sur VirtualBox avec host-only en adaptateur 1, l'interface sera très probablement `enp0s3`, pas `enp0s8`. Le cours lui-même attend `default via 10.0.2.2 dev enp0s3` pour la route NAT, ce qui confirme que `enp0s3` existe.
2. **DNS netplan** : Remplacer `nameservers: [192.168.56.1]` par un serveur DNS valide (ou supprimer la ligne) pour permettre `apt-get update` depuis l'NAT.
3. **Dépôt MySQL 8.0 obligatoire** : Forcer `mysql-8.0` (pas 8.4) via `dpkg-reconfigure mysql-apt-config` avant tout `apt-get install mysql-cluster-community-*`. Réimporter la clé GPG (`/etc/apt/keyrings/mysql.gpg`) car la clé MySQL est expirée sur Ubuntu 24.04.
4. **Initialisation du datadir MySQL** : Ajouter `mysqld --initialize-insecure` (ou `--initialize`) avant le premier lancement de `mysqld --ndbcluster … --daemonize`, sinon mysqld refuse de démarrer.
5. **AppArmor** : Passer le profil `usr.sbin.mysqld` en mode `complain` ou ajouter des alias pour `/var/lib/mysql-cluster/**` et `/etc/mysql-cluster-tls/**`, sinon mysqld ne pourra pas lire les certificats TLS ni écrire dans les DataDir NDB.
6. **SSH root** : Activer `PermitRootLogin yes` (ou配置 une clé SSH root) et démarrer `sshd`, sinon `scp root@…` et la session SSH root supposée par le cours échouent.
7. **`pkill -x ndbmtd` sur VM2** : Arrête les deux nodes de stockage simultanément (Lab-10) → interruption du stockage. Prévoir une fenêtre de maintenance (déjà noté dans le cours).
8. **`kill <PID_…>` placeholder** (Lab-14 é3) : Remplacer par une identification automatique des PID (ex. `pgrep ndbmtd` puis `kill`) pour être exécutoire.
9. **Redondance `mysqld --daemonize &`** : `--daemonize` met déjà en arrière-plan ; le `&` est redondant (inoffensif) mais à nettoyer.
10. **`systemctl restart mysql` (Lab-12)** : Incohérent avec le lancement manuel ; à supprimer ou remplacer par un redémarrage du processus mysqld manuel (Lab-12 est de toute façon théorique).

---

## 5. PRÉREQUIS MANQUANTS IDENTIFIÉS DANS LE COURS

- **ISO Ubuntu Server 24.04 LTS** : nécessaire pour Cas B (Lab-01 é3/é5), non listé comme fichier fourni dans le dépôt.
- **Paquets `.deb` MySQL Cluster en cache local** : le lab isolé (pas d'Internet permanent) suppose une installation depuis `/var/cache/apt/archives/` ou un dépôt local, mais aucun `.deb` n'est présent dans le dépôt et la procédure cache n'est pas détaillée.
- **Clé GPG MySQL valide** : expirée (EXPKEYSIG B7B3B788A8D3785C) ; la procédure de réimport est documentée uniquement dans la partie "Dépannage" de Lab-02, pas dans la procédure principale.
- **Utilisateur système `mysql`** : nécessaire pour `--user=mysql` ; créé par le paquet `mysql-cluster-community-server` mais non vérifié comme prérequis.
- **Datadir MySQL initialisé** : prérequis implicite pour `mysqld --ndbcluster --daemonize`, non documenté comme étape à réaliser.
- **`openssl`** : déclaré comme prérequis (Lab-14 é2) mais pas vérifié par une commande `dpkg -l openssl`.
- **sshd + accès root** : supposé ("accès root sur les trois VM, mot de passe dans .env") mais aucune commande ne configure `/etc/ssh/sshd_config` ni `PermitRootLogin`.
- **Repertoire `preuves/`** : AGENTS.md impose des fichiers de preuve horodatés (`# date:`, `# cmd:`, `# rc=`) pour chaque commande, mais aucun lab ne référence de chemin `preuves/…` concret ; la convention n'est pas appliquée dans les chapitres.
- **Snapshot `propre-avant-lab`** : déclaré prérequis (Lab-01 é8) mais il revient à l'apprenant/hôte de le prendre via VirtualBox ; pas de commande de création dans le lab (seulement `VBoxManage snapshot … list` pour vérification).

---

## Récapitulatif des NodeId, IP et fichiers de configuration (canonique parcours)

| NodeId | Type | Processus | VM | IP | HostName | DataDir |
|---|---|---|---|---|---|---|
| 1 | Gestion | ndb_mgmd | VM1 | 192.168.56.10 | gestion-sql | /var/lib/mysql-cluster |
| 2 | Stockage | ndbmtd | VM2 | 192.168.56.11 | stockage | /var/lib/mysql-cluster/ndb_2 |
| 3 | Stockage | ndbmtd | VM2 | 192.168.56.11 | stockage | /var/lib/mysql-cluster/ndb_3 |
| 4 | SQL | mysqld | VM1 | 192.168.56.10 | gestion-sql | (datadir MySQL) |
| 5 | SQL | mysqld | VM3 | 192.168.56.12 | mysql-node3 | (datadir MySQL) |
| 6 | Stockage (ajout/suppr/remplacement) | ndbmtd | VM2 | 192.168.56.11 | stockage | /var/lib/mysql-cluster/ndb_6 |

**Fichiers de configuration créés/modifiés dans les labs :**
- `/etc/netplan/01-netcfg.yaml` (VM1/2/3, Lab-01 é6)
- `/var/lib/mysql-cluster/config.ini` (VM1, Lab-02 é5, modifié Lab-05 é2b, Lab-08 é6, Lab-10 é3b, Lab-14 é1b)
- Sauvegardes : `config.ini.save`, `config.ini.pre-node6`, `config.ini.bak.optim`, `config.ini.bak.tls` (VM1)
- `/etc/mysql-cluster-tls/{ca,mgmd,ndbd,mysqld}-{cert,key,req}.pem` (VM1, copiés sur VM2/VM3, Lab-14 é2)
- `/etc/mysql/mysql.conf.d/replication.cnf` (Lab-12 é2, théorique)
- `/var/lib/mysql-cluster/clusterB/config.ini` (VM3, Lab-12 é4, théorique)

**Fin de l'audit.**