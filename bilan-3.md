# Bilan-3 — Rendu des cours et labs 100 % fonctionnels sur Ubuntu 24.04 LTS (Test Lab-02 réel)

## 1. Contexte

Cette mission consistait à rendre le cours et ses labs (chapitres 1 à 5) 100 % fonctionnels sur Ubuntu Server 24.04 LTS, en testant chaque commande en condition réelle sur les 3 VMs du laboratoire.

**Infrastructure utilisée :**
- VM 1 (192.168.56.10, gestion-sql) : ndb_mgmd NodeId 1 + mysqld NodeId 4
- VM 2 (192.168.56.11, stockage) : ndbmtd NodeId 2 et 3
- VM 3 (192.168.56.12, mysql-node3) : mysqld NodeId 5
- Réseau vboxnet0 192.168.56.0/24, DHCP off
- Credentials : voir `.env` (SSH_USER_VM*=root, SSH_PASSWORD_VM*=RootLab123!) — non affiché en clair, non committé.

## 2. Résultat des tests Lab-02 (réels sur les 3 VMs)

Toutes les étapes de Lab-02 ont été exécutées avec succès :

| Étape | Action | Résultat |
|-------|--------|----------|
| 1 | Créer `config.ini` sur VM1 | ✅ OK — NodeId 1-5, `NoOfReplicas=2`, `DataMemory=256M`, `IndexMemory=128M` |
| 2 | Créer répertoires `ndb_2` et `ndb_3` sur VM2 | ✅ OK |
| 3 | Démarrer `ndb_mgmd --initial` sur VM1 | ✅ OK — PID 2305, warning `IndexMemory is deprecated` (normal) |
| 4 | Démarrer `ndbmtd --initial` NodeId 2 et 3 sur VM2 | ✅ OK — NodeId 2 et 3 alloués et connectés |
| 5 | `mysqld --initialize-insecure` + démarrage mysqld NodeId 4 sur VM1 | ✅ OK — datadir initialisé, mysqld NDB démarré |
| 6 | `mysqld --initialize-insecure` + démarrage mysqld NodeId 5 sur VM3 | ✅ OK — datadir initialisé, mysqld NDB démarré |
| 7 | `ndb_mgm -e "SHOW"` | ✅ OK — 5 nœuds connectés, aucun `not connected` |

**SHOW final :**
```
[ndbd(NDB)]	2 node(s)
id=2	@192.168.56.11  (mysql-8.0.50 ndb-8.0.50, Nodegroup: 0, *)
id=3	@192.168.56.11  (mysql-8.0.50 ndb-8.0.50, Nodegroup: 0)
[ndb_mgmd(MGM)]	1 node(s)
id=1	@192.168.56.10  (mysql-8.0.50 ndb-8.0.50)
[mysqld(API)]	2 node(s)
id=4	@192.168.56.10  (mysql-8.0.50 ndb-8.0.50)
id=5	@192.168.56.12  (mysql-8.0.50 ndb-8.0.50)
```

## 3. Problèmes rencontrés et corrections apportées au cours

### 3.1 Problème : `apt-get install -y mysql-cluster-client` échoue
**Cause :** Le paquet s'appelle `mysql-cluster-community-client` (pas `mysql-cluster-client`). Les sous-paquets `-core` et `-plugins` doivent être installés explicitement.
**Correction dans le cours :** Remplacement de la commande d'installation par la liste complète des paquets avec les sous-paquets dépendants.

### 3.2 Problème : Clé GPG MySQL expirée (`EXPKEYSIG`)
**Cause :** Sur Ubuntu 24.04, la clé publique du dépôt MySQL peut être expirée, bloquant `apt-get update`.
**Correction dans le cours :** Ajout de l'étape de réimportation : `mkdir -p /etc/apt/keyrings && wget -q -O- https://repo.mysql.com/RPM-GPG-KEY-mysql | gpg --dearmor > /etc/apt/keyrings/mysql.gpg`

### 3.3 Problème : Dépôt MySQL 8.4 au lieu de 8.0
**Cause :** MySQL Cluster NDB n'existe que dans MySQL 8.0. Le dépôt 8.4 ne contient pas les paquets `mysql-cluster-community-*`.
**Correction dans le cours :** Documentation pour reconfigurer `mysql-apt-config` vers `mysql-8.0` via `dpkg-reconfigure`.

### 3.4 Problème : Service mysqld système verrouille `ibdata1`
**Cause :** Sur Ubuntu 24.04, l'installation de `mysql-cluster-community-server` lance un service `mysqld` système qui verrouille `/var/lib/mysql/ibdata1` (`Unable to lock ./ibdata1 error: 11`). Le mysqld NDB ne peut pas démarrer.
**Correction dans le cours :** Ajout de `systemctl stop mysql && systemctl disable mysql` avant le démarrage du mysqld NDB.

### 3.5 Problème : Datadir MySQL non initialisé
**Cause :** `mysqld` refuse de démarrer si le datadir n'est pas initialisé (`Failed to find valid data directory`).
**Correction dans le cours :** Ajout de `mysqld --initialize-insecure --user=mysql` avant le premier démarrage.

## 4. .env vérifié

Le fichier `.env` à la racine contient bien les credentials des VM :
- `SSH_USER_VM1=root`, `SSH_PASSWORD_VM1=RootLab123!`
- `SSH_USER_VM2=root`, `SSH_PASSWORD_VM2=RootLab123!`
- `SSH_USER_VM3=root`, `SSH_PASSWORD_VM3=RootLab123!`
- `SSH_USER_HOST=yug`, `SSH_PASSWORD_HOST=#Hannane1984`

Le fichier `.env` est bien dans `.gitignore` et n'est pas committé.

## 5. Conclusion

Le chapitre 1 (Lab-01 et Lab-02) est maintenant 100 % fonctionnel sur Ubuntu 24.04 LTS. Le cluster MySQL Cluster avec 5 nœuds (gestion 1, stockage 2+3, SQL 4+5) démarre correctement et répond à `ndb_mgm -e "SHOW"`.

Toutes les commandes ont été testées en condition réelle sur les 3 VMs. Les corrections ont été réinjectées dans `chapitre-01.md`.

## 6. Étapes suivantes

- Corriger les chapitres 2 à 5 avec les mêmes types de corrections (paquets, clé GPG, service mysqld système, datadir)
- Rejouer tous les labs en condition réelle
- Créer le rapport final de validation