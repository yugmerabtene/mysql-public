# Chapitre 1 — Introduction et installation de MySQL Cluster

## Objectif du chapitre

À la fin du chapitre, l'apprenant doit pouvoir décrire l'architecture de MySQL Cluster, identifier ses composants, installer les composants sur les deux VMs du lab et vérifier l'intégrité de l'installation avec la commande `ndb_mgm -e "SHOW"`.

## Avertissement et périmètre

- Cibles autorisées : VM 1 (192.168.56.10, nœud de gestion + SQL) et VM 2 (192.168.56.11, nœuds de stockage 1 et 2).
- Réseau : VirtualBox Host-only `vboxnet0`, `192.168.56.0/24`, DHCP désactivé, pas d'accès Internet pendant les labs.
- Données : factices uniquement, marquées `LAB-ONLY`. Aucune donnée de production, aucune cible réelle.
- Snapshots : prise d'un snapshot propre avant chaque manipulation, rollback après.
- Actions interdites : aucun mode pont, aucune redirection NAT, aucun accès Internet depuis les VMs pendant le lab.

## Durée estimée

- Durée totale : 6 heures (2 labs de 3 heures).
- Lab-01 : 3 heures.
- Lab-02 : 3 heures.

## Prérequis

| Élément | Détail | Vérification |
|---|---|---|
| VM 1 | Ubuntu Server 24.04 LTS, 1 vCPU, 1 Go RAM, 15 Go disque, IP 192.168.56.10 | SSH joignable depuis l'hôte |
| VM 2 | Ubuntu Server 24.04 LTS, 1 vCPU, 1 Go RAM, 15 Go disque, IP 192.168.56.11 | SSH joignable depuis l'hôte |
| Réseau | vboxnet0, 192.168.56.0/24, DHCP désactivé | `ping 192.168.56.10` et `ping 192.168.56.11` depuis l'hôte |
| ISO | `iso/ubuntu-24.04.5-autoinstall.iso` présent sur l'hôte | `ls -lh iso/` |
| Snapshot | `propre-jour-1` pris sur chaque VM avant le module | Snapshot listé dans VirtualBox |
| Outil | `ndb_mgm`, `ndb_mgmd`, `ndbmtd`, `mysqld` installés sur les VMs | `which ndb_mgm` retourne un chemin |

## Vocabulaire

| Terme | Définition |
|---|---|
| Nœud de gestion | Serveur qui gère la configuration du cluster MySQL (`ndb_mgmd`). |
| Nœud de stockage | Serveur qui stocke les données du cluster (`ndbmtd` ou `ndbd`). |
| Nœud SQL | Serveur MySQL qui fournit l'interface SQL au cluster (`mysqld` avec moteur NDB). |
| NDB | Moteur de stockage de MySQL Cluster, distribué et en mémoire. |
| Split-brain | Situation où le cluster est partitionné en deux groupes qui ne peuvent plus communiquer. |
| LAB-ONLY | Identifiant ou mot de passe factice, valide uniquement dans le lab isolé. |

## Modèle de menace et cartographie de référence

| Opération | ID | Composant | Source de données | Règle de détection | Mitigation |
|---|---|---|---|---|---|
| Présentation des composants | NDB-01 | Architecture | Documentation MySQL Cluster | Vérifier présence des 3 types de nœuds | Documenter l'architecture avant installation |
| Installation composants | NDB-03 | Tous les nœuds | `apt-get` ou RPM, sortie d'installation | Vérifier que `ndb_mgm` et `mysqld` sont présents | Installation depuis dépôt officiel MySQL |
| Configuration initiale | NDB-04 | Nœud de gestion | Fichier `config.ini` | Vérifier que `ndb_mgmd` démarre sans erreur | Sauvegarder `config.ini` avant modification |
| Vérification intégrité | NDB-05 | Cluster entier | `ndb_mgm -e "SHOW"` | Alerte si un nœud n'est pas connecté | Redémarrer les nœuds dans l'ordre : MGM, stockage, SQL |

## Plan d'installation maître

| Ordre | Lab | Objectif | Cible | Tactique | Opérations de référence | Preuve attendue |
|---|---|---|---|---|---|---|
| 1 | Lab-01 | Installer les composants MySQL Cluster | VM 1 et VM 2 | Installation depuis dépôt MySQL, configuration initiale | NDB-03, NDB-04 | Sortie d'installation, fichier `config.ini` |
| 2 | Lab-02 | Vérifier l'intégrité de l'installation | VM 1 | Démarrage des nœuds, `ndb_mgm -e "SHOW"` | NDB-05 | Capture `SHOW` avec tous les nœuds connectés |

## Vérification préalable

| Contrôle | Méthode | Résultat attendu | Preuve |
|---|---|---|---|
| Connectivité VM 1 | `ping 192.168.56.10` depuis l'hôte | Réponse reçue, 0 % de perte | `preuves/ch1-lab0/ping-vm1.txt` |
| Connectivité VM 2 | `ping 192.168.56.11` depuis l'hôte | Réponse reçue, 0 % de perte | `preuves/ch1-lab0/ping-vm2.txt` |
| Présence des binaires | `which ndb_mgm ndb_mgmd mysqld` sur chaque VM | Chemins retournés pour chaque binaire | `preuves/ch1-lab0/which-nodes.txt` |

## Lab-01 — Installation des composants MySQL Cluster

### Énoncé / Contexte

Installer les composants MySQL Cluster (gestion, stockage, SQL) sur les deux VMs du lab. Ce lab illustre les opérations `NDB-03` (installation des composants) et `NDB-04` (configuration initiale) du parcours. Il précède toute vérification de l'intégrité du cluster.

### Outils et commandes utilisées

| Outil | Commande | Rôle |
|---|---|---|
| `wget` | `wget https://dev.mysql.com/get/...` | Téléchargement du paquet MySQL Cluster |
| `apt-get` | `apt-get install ...` | Installation des paquets `.deb` |
| `ndb_mgmd` | `ndb_mgmd --config-file=...` | Démarrage du nœud de gestion |
| `ndbmtd` | `ndbmtd` | Démarrage des nœuds de stockage |
| `mysqld` | `mysqld --ndbcluster` | Démarrage du nœud SQL |
| `ndb_mgm` | `ndb_mgm -e "SHOW"` | Vérification de l'état du cluster |

### Commande et laboratoire étape par étape

#### Étape 1 — Télécharger le paquet MySQL Cluster sur la VM 1

**But** — Récupérer le paquet d'installation MySQL Cluster sur le nœud de gestion + SQL.

**Machine** — VM 1 (192.168.56.10), nœud de gestion + SQL.

**Prérequis** — VM 1 démarrée, SSH accessible, réseau vboxnet0 opérationnel.

> **Machine** : 192.168.56.10 | **Terminal** : SSH depuis l'hôte | **Utilisateur** : `root` | **Répertoire** : `/tmp`

**Exemple de commande**

```bash
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.0/mysql-cluster-community-server_8.0.42-1ubuntu24.04_amd64.deb -P /tmp
```

**Explication de la commande**

- `wget` : télécharge le fichier depuis l'URL indiquée.
- `https://dev.mysql.com/get/...` : URL du dépôt officiel MySQL pour le paquet serveur du cluster.
- `-P /tmp` : enregistre le fichier téléchargé dans le répertoire temporaire.
- `piège` : l'URL peut évoluer selon la version ; vérifier la dernière version sur dev.mysql.com avant le lab.

**Résultat attendu**

```text
--2026-11-20 10:00:00--  https://dev.mysql.com/get/...
Résolution de dev.mysql.com (dev.mysql.com)… 134.217.16.123
Connexion à dev.mysql.com (dev.mysql.com):443… connecté.
requête HTTP transmise, en attente de la réponse… 200 OK
Longueur : 123456789 (118M) [application/x-deb]
Enregistré : « /tmp/mysql-cluster-community-server_8.0.42-1ubuntu24.04_amd64.deb »
```

**Preuve** : `preuves/ch1-lab1/wget-vm1.txt`, avec `# date:`, `# cmd:`, `# rc=`.

#### Étape 2 — Installer le paquet sur la VM 1

**But** — Installer le serveur MySQL Cluster sur le nœud de gestion + SQL.

**Machine** — VM 1 (192.168.56.10), nœud de gestion + SQL.

**Prérequis** — Paquet `.deb` présent dans `/tmp`, droits root.

> **Machine** : 192.168.56.10 | **Terminal** : SSH depuis l'hôte | **Utilisateur** : `root` | **Répertoire** : `/tmp`

**Exemple de commande**

```bash
apt-get install -y ./mysql-cluster-community-server_8.0.42-1ubuntu24.04_amd64.deb
```

**Explication de la commande**

- `apt-get install` : installe un paquet Debian et ses dépendances.
- `-y` : répond automatiquement oui aux questions de confirmation.
- `./...deb` : installe le paquet local depuis le répertoire courant.
- `piège` : si des dépendances manquent, `apt-get` peut échouer ; exécuter `apt-get -f install` ensuite.

**Résultat attendu**

```text
Lecture des listes de paquets… Fait
Construction de l'arbre des dépendances… Fait
Lecture des informations d'état… Fait
Note : installation de « mysql-cluster-community-server » à la place de « ./...deb »
Les paquets supplémentaires suivants seront installés : ...
0 mis à jour, 1 nouvellement installés, 0 à enlever et 0 non mis à jour.
Paramétrage de mysql-cluster-community-server (8.0.42-1ubuntu24.04) …
```

**Preuve** : `preuves/ch1-lab1/apt-install-vm1.txt`, avec `# date:`, `# cmd:`, `# rc=`.

#### Étape 3 — Installer les composants sur la VM 2

**But** — Installer les composants de stockage sur le deuxième nœud du cluster.

**Machine** — VM 2 (192.168.56.11), nœuds de stockage 1 et 2.

**Prérequis** — VM 2 démarrée, SSH accessible, même version du paquet transférée ou retéléchargée.

> **Machine** : 192.168.56.11 | **Terminal** : SSH depuis l'hôte | **Utilisateur** : `root` | **Répertoire** : `/tmp`

**Exemple de commande**

```bash
scp /tmp/mysql-cluster-community-server_8.0.42-1ubuntu24.04_amd64.deb root@192.168.56.11:/tmp/ && ssh root@192.168.56.11 "apt-get install -y /tmp/mysql-cluster-community-server_8.0.42-1ubuntu24.04_amd64.deb"
```

**Explication de la commande**

- `scp` : copie le paquet de la VM 1 vers la VM 2.
- `root@192.168.56.11:/tmp/` : destination sur la VM 2.
- `&&` : enchaîne la commande SSH uniquement si la copie réussit.
- `ssh root@192.168.56.11 "..."` : exécute l'installation à distance sur la VM 2.
- `piège` : l'authentification SSH doit être configurée (clé ou mot de passe `LAB-ONLY`) avant cette étape.

**Résultat attendu**

```text
mysql-cluster-community-server_8.0.42-1ubuntu24.04_amd64.deb  100% 118MB  11.8MB/s   00:10
Lecture des listes de paquets… Fait
Paramétrage de mysql-cluster-community-server (8.0.42-1ubuntu24.04) …
```

**Preuve** : `preuves/ch1-lab1/apt-install-vm2.txt`, avec `# date:`, `# cmd:`, `# rc=`.

#### Étape 4 — Créer le fichier de configuration du nœud de gestion sur la VM 1

**But** — Rédiger le fichier `config.ini` qui définit la topologie du cluster (1 nœud de gestion, 2 nœuds de stockage, 1 nœud SQL).

**Machine** — VM 1 (192.168.56.10), nœud de gestion + SQL.

**Prérequis** — `ndb_mgmd` installé, répertoire `/var/lib/mysql-cluster` existant.

> **Machine** : 192.168.56.10 | **Terminal** : SSH depuis l'hôte | **Utilisateur** : `root` | **Répertoire** : `/var/lib/mysql-cluster`

**Exemple de commande**

```bash
cat > /var/lib/mysql-cluster/config.ini << 'EOF'
[ndb_mgmd default]
DataDir = /var/lib/mysql-cluster

[ndbd default]
NoOfReplicas = 2
DataMemory = 256M
IndexMemory = 128M

[tcp default]

[ndb_mgmd]
Id = 1
HostName = 192.168.56.10

[ndbd]
Id = 2
HostName = 192.168.56.11

[ndbd]
Id = 3
HostName = 192.168.56.11

[mysqld]
Id = 4
HostName = 192.168.56.10
EOF
```

**Explication de la commande**

- `cat > ... << 'EOF'` : écrit le contenu jusqu'au marqueur `EOF` dans le fichier cible.
- `[ndb_mgmd]` : section du nœud de gestion, `Id = 1`, `HostName = 192.168.56.10`.
- `[ndbd]` : sections des nœuds de stockage, `Id = 2` et `Id = 3`, tous deux sur `192.168.56.11` (collocation sur la même VM).
- `[mysqld]` : section du nœud SQL, `Id = 4`, `HostName = 192.168.56.10`.
- `NoOfReplicas = 2` : deux copies de chaque fragment de données pour la redondance.
- `piège` : les `Id` doivent être uniques dans le cluster ; deux nœuds ne peuvent pas partager le même `Id`.

**Résultat attendu**

```text
# Aucune sortie à l'écran ; le fichier est créé silencieusement.
```

**Preuve** : `preuves/ch1-lab1/config-ini-vm1.txt`, avec `# date:`, `# cmd:`, `# rc=`.

#### Étape 5 — Démarrer le nœud de gestion sur la VM 1

**But** — Lancer `ndb_mgmd` pour qu'il serve de point de configuration central au cluster.

**Machine** — VM 1 (192.168.56.10), nœud de gestion.

**Prérequis** — `config.ini` présent et valide, port 1186 libre.

> **Machine** : 192.168.56.10 | **Terminal** : SSH depuis l'hôte | **Utilisateur** : `root` | **Répertoire** : `/var/lib/mysql-cluster`

**Exemple de commande**

```bash
ndb_mgmd --config-file=/var/lib/mysql-cluster/config.ini --initial &
```

**Explication de la commande**

- `ndb_mgmd` : démon du nœud de gestion de MySQL Cluster.
- `--config-file=/var/lib/mysql-cluster/config.ini` : indique le fichier de topologie à charger.
- `--initial` : force l'initialisation propre du nœud de gestion (à n'utiliser qu'au premier démarrage).
- `&` : lance le processus en arrière-plan pour libérer le terminal.
- `piège` : `--initial` supprime les fichiers de configuration précédents ; ne pas l'utiliser sur un cluster déjà en production.

**Résultat attendu**

```text
MySQL Cluster Management Server 8.0.42
...
NDBT_ProgramExit: 0
```

**Preuve** : `preuves/ch1-lab1/ndb-mgmd-start-vm1.txt`, avec `# date:`, `# cmd:`, `# rc=`.

#### Étape 6 — Démarrer les nœuds de stockage sur la VM 2

**But** — Lancer les deux processus `ndbmtd` (node-id 2 et 3) sur le nœud de stockage.

**Machine** — VM 2 (192.168.56.11), nœuds de stockage 1 et 2.

**Prérequis** — Nœud de gestion démarré sur 192.168.56.10, répertoires de données créés.

> **Machine** : 192.168.56.11 | **Terminal** : SSH depuis l'hôte | **Utilisateur** : `root` | **Répertoire** : `/var/lib/mysql-cluster`

**Exemple de commande**

```bash
ndbmtd --ndb-connectstring=192.168.56.10 --initial &
```

**Explication de la commande**

- `ndbmtd` : démon multi-threaded de stockage NDB.
- `--ndb-connectstring=192.168.56.10` : adresse du nœud de gestion pour rejoindre le cluster.
- `--initial` : initialise le stockage proprement au premier démarrage.
- `&` : processus en arrière-plan.
- `piège` : si le nœud de gestion n'est pas joignable, `ndbmtd` échoue au démarrage.

**Résultat attendu**

```text
NDBT_ProgramExit: 0
```

**Preuve** : `preuves/ch1-lab1/ndbmtd-start-vm2.txt`, avec `# date:`, `# cmd:`, `# rc=`.

#### Étape 7 — Démarrer le nœud SQL sur la VM 1

**But** — Lancer `mysqld` avec le moteur NDB pour exposer l'interface SQL du cluster.

**Machine** — VM 1 (192.168.56.10), nœud SQL.

**Prérequis** — Nœuds de gestion et de stockage démarrés, base de données MySQL initialisée.

> **Machine** : 192.168.56.10 | **Terminal** : SSH depuis l'hôte | **Utilisateur** : `root` | **Répertoire** : `/var/lib/mysql`

**Exemple de commande**

```bash
mysqld --ndbcluster --ndb-connectstring=192.168.56.10 &
```

**Explication de la commande**

- `mysqld` : démon du serveur MySQL.
- `--ndbcluster` : active le moteur de stockage NDB sur cette instance SQL.
- `--ndb-connectstring=192.168.56.10` : indique le nœud de gestion pour la découverte du cluster.
- `piège` : si un autre `mysqld` utilise déjà le port 3306, le démarrage échoue.

**Résultat attendu**

```text
2026-11-20T10:15:00.000Z mysqld ready for connections
```

**Preuve** : `preuves/ch1-lab1/mysqld-start-vm1.txt`, avec `# date:`, `# cmd:`, `# rc=`.

### En conclusion

Les composants MySQL Cluster sont installés sur les deux VMs et les nœuds sont démarrés dans l'ordre requis : gestion (VM 1), stockage (VM 2), puis SQL (VM 1). Le cluster est prêt pour la vérification d'intégrité au Lab-02. Critères de réussite : `ndb_mgmd`, `ndbmtd` et `mysqld` en cours d'exécution sur les cibles prévues. Renvoi : passer au Lab-02 pour exécuter `ndb_mgm -e "SHOW"` et confirmer que tous les nœuds sont connectés.

## Lab-02 — Vérification de l'intégrité de l'installation

### Énoncé / Contexte

Vérifier que le cluster MySQL est correctement installé et que tous les nœuds sont connectés. Ce lab illustre l'opération `NDB-05` (vérification intégrité) du parcours. Il s'appuie sur l'installation réalisée au Lab-01.

### Outils et commandes utilisées

| Outil | Commande | Rôle |
|---|---|---|
| `ndb_mgm` | `ndb_mgm -e "SHOW"` | Affiche l'état de tous les nœuds du cluster |
| `ndb_config` | `ndb_config --query-all` | Affiche la configuration effective du cluster |

### Commande et laboratoire étape par étape

#### Étape 1 — Vérifier l'état du cluster avec ndb_mgm depuis la VM 1

**But** — Confirmer que le nœud de gestion, les deux nœuds de stockage et le nœud SQL sont connectés au cluster.

**Machine** — VM 1 (192.168.56.10), nœud de gestion + SQL.

**Prérequis** — Tous les nœuds démarrés (Lab-01 étapes 5 à 7), `ndb_mgm` installé.

> **Machine** : 192.168.56.10 | **Terminal** : SSH depuis l'hôte | **Utilisateur** : `root` | **Répertoire** : `/root`

**Exemple de commande**

```bash
ndb_mgm -e "SHOW" | tee preuves/ch1-lab2/ndb-show.txt 2>&1
```

**Explication de la commande**

- `ndb_mgm` : client de gestion du cluster MySQL.
- `-e "SHOW"` : exécute la commande `SHOW` et quitte.
- `| tee preuves/ch1-lab2/ndb-show.txt` : affiche la sortie à l'écran et l'enregistre simultanément dans le fichier de preuve.
- `2>&1` : redirige les erreurs (stderr) vers la sortie standard pour qu'elles soient aussi capturées.
- `piège` : si un nœud manque, sa ligne apparaît avec l'état `not connected` ; investiguer avant de considérer le lab réussi.

**Résultat attendu**

```text
Connected to Management Server at: 192.168.56.10:1186
Cluster Configuration
---------------------
[ndbd(NDB)]     2 node(s)
id=2    @192.168.56.11 (Version: 8.0.42, Nodegroup: 0, *)
id=3    @192.168.56.11 (Version: 8.0.42, Nodegroup: 0)

[ndb_mgmd(MGM)] 1 node(s)
id=1    @192.168.56.10 (Version: 8.0.42)

[mysqld(API)]   1 node(s)
id=4    @192.168.56.10 (Version: 8.0.42)
```

**Preuve** : `preuves/ch1-lab2/ndb-show.txt`, avec `# date:`, `# cmd:`, `# rc=`.

#### Étape 2 — Interroger la configuration complète du cluster

**But** — Confirmer que les paramètres de configuration sont correctement propagés à tous les nœuds.

**Machine** — VM 1 (192.168.56.10), nœud de gestion + SQL.

**Prérequis** — `ndb_mgm` a confirmé tous les nœuds connectés (étape précédente).

> **Machine** : 192.168.56.10 | **Terminal** : SSH depuis l'hôte | **Utilisateur** : `root` | **Répertoire** : `/root`

**Exemple de commande**

```bash
ndb_config --query-all | tee preuves/ch1-lab2/ndb-config.txt 2>&1
```

**Explication de la commande**

- `ndb_config` : outil d'interrogation de la configuration du cluster NDB.
- `--query-all` : retourne tous les paramètres de configuration de tous les nœuds.
- `piège` : la sortie est volumineuse ; vérifier uniquement les paramètres clés (`NoOfReplicas`, `DataMemory`, `HostName`) pour valider le lab.

**Résultat attendu**

```text
id=2    @192.168.56.11 (ndbd)
        Name = ndbd
        ...
id=3    @192.168.56.11 (ndbd)
        Name = ndbd
        ...
id=1    @192.168.56.10 (ndb_mgmd)
        Name = ndb_mgmd
        ...
id=4    @192.168.56.10 (mysqld)
        Name = mysqld
        ...
```

**Preuve** : `preuves/ch1-lab2/ndb-config.txt`, avec `# date:`, `# cmd:`, `# rc=`.

### En conclusion

L'installation est vérifiée : la commande `ndb_mgm -e "SHOW"` affiche les 4 nœuds attendus (1 gestion, 2 stockage, 1 SQL) tous en état connecté. Les opérations `NDB-03`, `NDB-04` et `NDB-05` sont réalisées. Critères de réussite : sortie `SHOW` complète sans nœud `not connected`, preuve horodatée conservée. Le chapitre 1 est terminé ; le prochain chapitre (Jour 2) couvrira l'architecture détaillée et l'administration des nœuds.

## Synthèse du chapitre

> **À retenir** — MySQL Cluster s'installe sur deux VMs : gestion+SQL sur 192.168.56.10, stockage (2 node-id) sur 192.168.56.11. L'intégrité se prouve avec `ndb_mgm -e "SHOW"` montrant tous les nœuds connectés.

## Erreurs fréquentes

| Symptôme | Cause probable | Solution |
|---|---|---|
| `ndb_mgm` ne se connecte pas | Nœud de gestion non démarré ou firewall | Démarrer `ndb_mgmd` sur 192.168.56.10, vérifier le port 1186 |
| Nœud de stockage `not connected` | `ndbmtd` ne rejoint pas le gestionnaire | Vérifier `--ndb-connectstring=192.168.56.10` |
| `mysqld` ne voit pas NDB | Moteur `--ndbcluster` absent | Relancer `mysqld` avec l'option `--ndbcluster` |

## Ressources et références

- Documentation MySQL Cluster officielle : https://dev.mysql.com/doc/mysql-cluster/
- Manuel de référence MySQL : https://dev.mysql.com/doc/refman/
- MySQL Cluster Manager : https://dev.mysql.com/doc/mysql-cluster-manager/
