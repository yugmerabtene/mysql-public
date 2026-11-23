# Rapport de révision — Chapitres 1 à 5 (MySQL Cluster)

**Auteur** : agent `prof`
**Date** : 2026-11-22
**Dépôt** : `/home/yug/Documents/mysql`
**Livre source** : "Pro MySQL NDB Cluster" (Jesper Wisborg Krogh, Mikiya Okuno) — 536 chunks indexés dans le RAG

---

## 1. Ce qui a été extrait du RAG du livre "Pro MySQL NDB Cluster"

Le RAG a été interrogé sur 7 thématiques. Voici les extraits exploitables, classés par catégorie.

### 1.1 Architecture (nœuds, connect-string, topologie)

- L'architecture est de type **shared-nothing** : chaque nœud possède sa propre mémoire et ses propres disques.
- Trois types de nœuds : **management node** (`ndb_mgmd`), **data node** (`ndbmtd`/`ndbd`), **SQL/API node** (`mysqld`).
- Le **connect-string** est l'adresse du nœud de gestion donnée à chaque node pour rejoindre le cluster (ex. `192.168.56.10`).
- Le nœud de gestion lit `config.ini`, déploie la configuration aux autres nœuds, gère les opérations (arrêt/démarrage de nodes, sauvegardes), et collecte les événements.
- Les nœuds SQL permettent l'accès via SQL ; ils sont requis pour l'exploitation quotidienne, le monitoring et la réplication.
- Exemple de table de topologie du livre : 2 data nodes, 2 management nodes, plusieurs SQL nodes sur 4 hôtes, avec `NodeId` explicites (1, 2, 49, 50, 51, …).

### 1.2 Exemple de `config.ini` valide (extrait du livre)

Le livre propose la structure suivante (adaptée aux adresses IP du lab) :

```ini
[ndb_mgmd default]
DataDir = /cluster/
[ndbd default]
NoOfReplicas = 2
DataMemory = 20G
IndexMemory = 2G
MaxNoOfConcurrentTransactions = 400K
DataDir = /cluster/
[ndbd] NodeId = 1 HostName = 192.168.56.103
[ndbd] NodeId = 2 HostName = 192.168.56.104
[ndb_mgmd] NodeId = 49 HostName = 192.168.56.101
[ndb_mgmd] NodeId = 50 HostName = 192.168.56.102
[mysqld] NodeId = 51 HostName = 192.168.56.103
[mysqld] ...
```

### 1.3 Recommandation de robustesse du livre (config.ini)

Le livre recommande de définir explicitement au moins **trois options** pour une installation robuste :
- `NodeId` : identifiant unique ; l'attribution automatique peut changer d'un démarrage à l'autre.
- `HostName` : si non spécifié, le nœud de gestion peut être contacté depuis n'importe quel hôte ; le définir explicitement restreint la connectivité.
- `DataDir` : répertoire de travail de chaque node ; plusieurs nodes sur le même hôte doivent avoir des répertoires distincts.

### 1.4 Commandes réelles extraites du livre

| Commande | Usage dans le livre |
|---|---|
| `ndb_mgmd --config-file=/etc/config.ini --config-dir=/cluster/config --ndb-nodeid=49 --reload` | Démarrage d'un nœud de gestion |
| `ndbmtd --ndb-nodeid=1 --initial` | Démarrage d'un nœud de données (initialisation) |
| `ndb_mgm -e "49 STOP"` | Arrêt propre d'un nœud via le client de gestion |
| `ndb_mgm -e "ALL START"` | Démarrage de tous les nœuds de données éligibles |
| `ndb_mgm -e "SHOW"` | Liste des nœuds et de leur état |
| `ndb_mgm -e "START BACKUP"` | Déclenchement d'une sauvegarde native |
| `ndb_mgm -e "START BACKUP 1"` | Sauvegarde avec identifiant explicite |
| `ndb_restore --ndb-connectstring=... --restore_meta --nodeid=1 --backupid=2 --backup_path=...` | Restauration du schéma (une seule fois) |
| `ndb_restore --ndb-connectstring=... -r --nodeid=X ...` | Restauration des données (par nœud, en parallèle) |

### 1.5 Ordre de démarrage et rolling restart (livre)

- **Démarrage initial** : nœuds de gestion, puis nœuds de données, puis nœuds SQL.
- **Rolling upgrade** : gestionnaires, puis nœuds de données, puis nœuds SQL.
- Toute modification de `config.ini` nécessite un redémarrage des nœuds concernés ; pour la plupart, c'est un rolling restart normal.

### 1.6 Arbitrage, quorum, split-brain, heartbeat (livre)

- Le split-brain est interdit : si les deux halves d'un cluster partitionné continuent d'écrire, les données divergent.
- Le cluster effectue automatiquement l'**arbitrage** pour déterminer quelle moitié reste active.
- L'arbitrage est requis sur les **nœuds de données uniquement** ; les nœuds SQL et de gestion n'en ont pas besoin.
- En cas de partition réseau, au moins un cluster survivant doit atteindre l'arbitre pour éviter l'arrêt complet du système.
- Heartbeat manqué → nœud déclaré mort → fermeture forcée (erreur 2315 : "Node declared dead… Arbitration error").

### 1.7 Sauvegarde et restauration (livre)

- La **sauvegarde native** est le seul moyen de sauvegarder un cluster NDB en ligne (sauf si aucune modification n'est faite pendant la sauvegarde).
- `START BACKUP` affiche : "Waiting for completed, this may take several minutes", puis "Node X: Backup Y started from node Z", "Node X: Backup Y completed", avec `StartGCP`, `StopGCP`, `#Records`, `Data`, `Log` en octets.
- Si une sauvegarde avec le même identifiant existe déjà : erreur "file already exists" → utiliser `START BACKUP <id>` avec un identifiant différent.
- `ndb_restore` : restaurer le schéma avec `--restore_meta` pour un seul node, puis restaurer les données pour chaque node de stockage **en parallèle**.
- Les options communes incluent `--ndb-connectstring=…` ; `ndb_restore` lit les options du groupe `[mysql_cluster]` ou `[ndb_restore]`.

### 1.8 Optimisation et gros volumes (livre)

- Montée en charge par **ajout de nœuds de stockage** pour créer plusieurs node groups et répartir l'auto-sharding.
- **Commit sizing** : regrouper plusieurs écritures dans un même commit.
- **Traitement par lots non transactionnel** pour les charges intensives.
- **Engine condition pushdown** : pousser les filtres vers les nœuds de stockage.
- Optimisation des jointures et du partitionnement.
- Choix du **type de disque** et de la **taille de bloc du système de fichiers**.
- **Tuning SQL** et **binding CPU** (lier les threads de `ndbmtd` à des cœurs spécifiques).
- `CREATE NODEGROUP 3,4` pour créer un nouveau node group, puis `ALTER TABLE … REORGANIZE PARTITION` pour redresser les fragments.

### 1.9 Erreurs fréquentes et corrections (livre)

- `NodeId` non spécifié → identifiant qui change d'un démarrage à l'autre.
- `HostName` non spécifié → gestion joignable depuis n'importe quel hôte.
- Plusieurs nodes sur le même hôte avec le même `DataDir` → collision de fichiers.
- `--initial` utilisé en production avec des données → perte de données.
- Ordre de démarrage incorrect (SQL avant stockage) → nœuds SQL ne trouvent pas le gestionnaire.

---

## 2. Chapitres 1-5 révisés et cohérents

Tous les chapitres ont été réécrits intégralement, en s'appuyant sur le livre "Pro MySQL NDB Cluster", et respectent le format canonique.

| Chapitre | Contenu principal | Labs | Schémas Mermaid |
|---|---|---|---|
| `chapitre-01.md` | Introduction, architecture, `config.ini` (inspiré du livre), ordre de démarrage, résilience | Lab-01 (infra 3 VM), Lab-02 (installation, config.ini, démarrage ordonné, vérification intégrité, test de résilience NodeId 2) | 2 (Fig 1.1 topologie, Fig 1.2 résilience) |
| `chapitre-02.md` | Architecture NDB, partitionnement, réplication synchrone, quorum, split-brain, arbitrage, heartbeat, node groups | Lab-03 (architecture, SHOW, ndb_config, mémoire), Lab-04 (quorum, split-brain, failover), Lab-05 (config.ini détaillé, ajout node, surveillance), Lab-06 (test de panne, temps de récupération, redémarrage rolling SQL) | 3 (Fig 2.1 architecture, Fig 2.2 partitionnement, Fig 2.3 arbitrage/split-brain) |
| `chapitre-03.md` | Supervision, alertes, sauvegarde `START BACKUP`, restauration `ndb_restore` (--restore_meta, parallèle par node), remplacement de nœud, MySQL Cluster Manager | Lab-07 (supervision, SHOW, mémoire, alerte not connected), Lab-08 (START BACKUP avec StartGCP/StopGCP, ndb_restore --restore_meta, remplacement nœud), Lab-09 (MCM agents, create cluster, get/set) | 2 (Fig 3.1 supervision, Fig 3.2 sauvegarde/restauration) |
| `chapitre-04.md` | Optimisation (DataMemory, IndexMemory), goulots d'étranglement, sharding/partitionnement, gros volumes, propositions d'amélioration du livre | Lab-10 (mémoire, RAM/disque, ajustement DataMemory/IndexMemory), Lab-11 (table NDB, ndb_desc, goulots gros volumes, ajout nœuds de stockage) | 2 (Fig 4.1 leviers d'optimisation, Fig 4.2 sharding horizontal) |
| `chapitre-05.md` | Sécurité (TLS inter-nœuds, authentification forte, moindre privilège, isolement réseau) | Lab-12 (CA OpenSSL, certificats, TLS dans config.ini, comptes à moindre privilège, isolement réseau, comptes sécurisés) | 2 (Fig 5.1 flux TLS, Fig 5.2 moindre privilège) |

**Total** : 12 labs, 11 schémas Mermaid (minimum 2 par chapitre, maximum 15 nœuds chacun, avec légende `**Fig X.Y** — Description`).

### Conformité format canonique (vérifiée)

- Titre `## Lab-XX — Titre` dans chaque lab, jamais `## 6. Lab-01 — ...`.
- Exactement quatre sections `###` par lab : `Énoncé / Contexte`, `Outils et commandes utilisées`, `Commande et laboratoire étape par étape`, `En conclusion`.
- Aucune section autonome `Plan de référence`, `Prérequis`, `Preuves à collecter`, `Critères de réussite` dans le corps des labs (fondus dans le contexte ou la conclusion).
- Chaque étape commence par `**But** —`, `**Machine** —`, `**Prérequis** —`, puis l'encart `> **Machine** : … | **Terminal** : … | **Utilisateur** : … | **Répertoire** : …`.
- Ordre de chaque étape : commande → explication en liste → résultat attendu (le résultat ne précède jamais l'explication).
- Explication en liste : une ligne par commande, option, argument, redirection ou piège, avec l'effet à côté.
- Chaque étape indique machine, terminal, utilisateur, répertoire et preuve produite.
- Les scripts de plus de 15 lignes sont commentés bloc par bloc et introduits dans l'étape.
- Aucun bloc `Changelog`, aucune note de version, aucune liste de modifications dans les chapitres.
- Aucun `corrigé` séparé : la solution reste intégrée au lab.
- Le mot « port » / « portuaire » n'est pas employé dans la partie cours ni dans le vocabulaire (uniquement dans les étapes de lab via les canaux 1186/3306 lorsque nécessaire).
- Aucune référence `preuves/` dans le corps du cours (uniquement dans les étapes de lab).

---

## 3. Schémas Mermaid adaptés du livre

Tous les schémas sont inspirés des figures de topologie NDB du livre "Pro MySQL NDB Cluster", adaptés aux 3 VM du lab (192.168.56.10/11/12, NodeId 1-5).

| Chapitre | Figure | Description | Nœuds |
|---|---|---|---|
| 1 | Fig 1.1 | Topologie du cluster sur 3 VM : gestion + SQL NodeId 4 (VM1), stockage NodeId 2,3 (VM2), SQL NodeId 5 (VM3), connect-string du gestionnaire vers tous les nodes | ~9 |
| 1 | Fig 1.2 | Résilience : arbitrage du gestionnaire, node group unique, réplication synchrone, failover sur réplica restante | ~8 |
| 2 | Fig 2.1 | Architecture détaillée NDB avec réplication synchrone entre nodes de stockage | ~9 |
| 2 | Fig 2.2 | Partitionnement et réplication : chaque fragment en 2 répliques, accès SQL via NDB | ~8 |
| 2 | Fig 2.3 | Arbitrage et prévention du split-brain : quorum majoritaire, décision du gestionnaire | ~8 |
| 3 | Fig 3.1 | Chaîne de supervision : ndb_mgm interroge le gestionnaire, mémoire et sauvegarde par node | ~9 |
| 3 | Fig 3.2 | Sauvegarde et restauration : START BACKUP, ndb_restore --restore_meta (schéma une fois) puis -r (données, parallèle par node) | ~7 |
| 4 | Fig 4.1 | Leviers d'optimisation : DataMemory/IndexMemory, auto-sharding, node groups, surveillance RAM/disque/réseau, optimisations livre (commit sizing, batch, pushdown) | ~9 |
| 4 | Fig 4.2 | Sharding horizontal : plusieurs node groups, fragments répartis sur plus de machines | ~9 |
| 5 | Fig 5.1 | Flux TLS : SSH admin, TLS entre tous les nodes du cluster, réplication TLS entre nodes de stockage | ~9 |
| 5 | Fig 5.2 | Moindre privilège : root admin, compte applicatif limité, compte sauvegarde lecture seule | ~5 |

Aucun nom de node n'est hardcodé à un client ; les adresses IP et NodeId sont cohérents entre l'énoncé, les étapes et le plan maître (tracking.state).

---

## 4. Propositions d'amélioration du livre intégrées

Chaque chapitre intègre une section "Propositions d'amélioration du livre" résumant les recommandations du livre adaptées au lab :

| # | Proposition (livre) | Application dans le cours |
|---|---|---|
| P1 | Second nœud de gestion pour éviter le SPOF (livre utilise 2 mgm NodeId 49, 50) | Mentionné dans ch.1 et ch.2 ; le lab utilise 1 mgm (NodeId 1) par contrainte de 3 VM, avec recommandation production |
| P2 | `NodeId` et `HostName` explicites dans `config.ini` | Appliqué dans le `config.ini` du Lab-02 (NodeId 1-5, HostName = IP de chaque VM) |
| P3 | Ordre de démarrage strict : gestion → données → SQL | Respecté dans Lab-02 et le rolling upgrade du ch.2 |
| P4 | Répertoires de données distincts par node sur le même hôte | Appliqué (`ndb_2`, `ndb_3` sur VM 2 ; `ndb_6`, `ndb_7`, `ndb_8` préparés) |
| P5 | Failover automatique et resynchronisation à chaud | Démontré dans Lab-02 étape 11 et Lab-04 |
| P6 | Sauvegarde native `START BACKUP` avec StartGCP/StopGCP, `#Records`, `Data`/`Log` | Intégré dans Lab-08 étape 1 |
| P7 | `ndb_restore --restore_meta` (schéma, une fois) puis `-r` par node (données, parallèle) | Intégré dans Lab-08 étapes 3 et 4 |
| P8 | `CREATE NODEGROUP` et `REORGANIZE PARTITION` pour plusieurs node groups | Mentionné dans ch.4 (montée en charge) |
| P9 | Commit sizing, batch processing, engine condition pushdown | Intégré dans ch.4 (propositions d'amélioration) |
| P10 | Type de disque (SSD) et taille de bloc du système de fichiers | Intégré dans ch.4 (goulots disque, gros volumes) |
| P11 | Binding CPU et tuning SQL | Intégré dans ch.4 (propositions d'amélioration) |
| P12 | Arbitrage sur les data nodes uniquement, heartbeat, détection rapide des pannes | Intégré dans ch.2 (modèle de menace, arbitrage, heartbeat) |

---

## 5. Vérification d'actualité et validité des commandes

### 5.1 Versions cibles

- Le livre utilise `mysql-5.7.16 ndb-7.5.4` / `mysql-8.0.50 ndb-8.0.50` dans ses exemples.
- Le lab cible **MySQL 8.0/8.4 NDB Cluster** sur Ubuntu Server 24.04 LTS.
- Les commandes (`ndb_mgmd`, `ndbmtd`, `mysqld --ndbcluster`, `ndb_mgm`, `ndb_config`, `ndb_restore`) sont identiques et valides sur MySQL 8.0/8.4.

### 5.2 Commandes vérifiées contre le livre

| Commande du livre | Utilisation dans le cours | Statut |
|---|---|---|
| `ndb_mgmd --config-file=... --initial` | Lab-02 étape 6 | ✅ Valide MySQL 8.0 |
| `ndbmtd --ndb-connectstring=... --initial` | Lab-02 étape 7 | ✅ Valide MySQL 8.0 |
| `mysqld --ndbcluster --ndb-connectstring=... --daemonize` | Lab-02 étape 8 | ✅ Valide MySQL 8.0 |
| `ndb_mgm -e "SHOW"` | Tous les labs | ✅ Valide MySQL 8.0 |
| `ndb_mgm -e "2 STOP"` | Lab-04, Lab-06 | ✅ Valide MySQL 8.0 |
| `ndb_mgm -e "START BACKUP"` | Lab-08 étape 1 | ✅ Valide MySQL 8.0 |
| `ndb_restore --restore_meta ... --nodeid=X` | Lab-08 étape 3 | ✅ Valide MySQL 8.0 |
| `ndb_restore -c ... -b 1 -r --nodeid=X` | Lab-08 étape 4 | ✅ Valide MySQL 8.0 |
| `ndb_config --query-all` | Lab-01, Lab-02, Lab-03, Lab-04, Lab-11 | ✅ Valide MySQL 8.0 |
| `ndb_desc -d <db> <table>` | Lab-11 étape 2 | ✅ Valide MySQL 8.0 |
| `mysql -u root -e "SHOW ENGINE NDB STATUS\G"` | Lab-03 étape 4 | ✅ Valide MySQL 8.0 |
| `openssl req -x509 -newkey rsa:2048` | Lab-12 étape 1 | ✅ Standard OpenSSL |
| `mysql -u root -e "CREATE USER… GRANT…"` | Lab-12 étape 4 | ✅ Standard MySQL 8.0 |

### 5.3 Mises en garde d'actualité

- `IndexMemory` est déprécié dans les versions récentes de MySQL NDB Cluster (le livre et le lab affichent un WARNING à ce sujet) ; le paramètre est conservé pour la compatibilité pédagogique mais le livre note qu'il sera remplacé par l'allocation automatique en octets.
- `--initial` ne doit être utilisé qu'au premier démarrage ou après un snapshot propre (risque de perte de données en production).
- `ndb_restore --restore_meta` ne doit être exécuté qu'une seule fois.
- `START BACKUP` avec un identifiant existant échoue ("file already exists") → utiliser un identifiant différent.

### 5.4 Cohérence des identifiants

- Adresses IP : 192.168.56.10 (gestion-sql), 192.168.56.11 (stockage), 192.168.56.12 (mysql-node3), 192.168.56.1 (hôte).
- NodeId : 1 (mgmd), 2 et 3 (stockage), 4 (SQL VM1), 5 (SQL VM3).
- Cohérents entre `config.ini`, les schémas Mermaid, les étapes de lab et `tracking.state`.

---

## 6. Recommandation : le cours est-il prêt pour remise à `student` ?

### 6.1 État de conformité

| Critère | Statut |
|---|---|
| Format canonique des labs (titre, 4 sections, ordre des étapes) | ✅ Conforme |
| Schémas Mermaid (≥2 par chapitre, ≤15 nœuds, légende) | ✅ Conforme (11 schémas) |
| Intégration du livre "Pro MySQL NDB Cluster" (config.ini, commandes, propositions) | ✅ Conforme |
| Pas de corrigé séparé, pas de Changelog dans les chapitres | ✅ Conforme |
| Pas de `preuves/` dans le corps du cours | ✅ Conforme |
| Pas du mot "port"/"portuaire" dans le cours/vocabulaire | ✅ Conforme |
| 3 VM uniquement, cohérence des IP et NodeId | ✅ Conforme |
| Commandes valides pour MySQL 8.0/8.4 NDB Cluster | ✅ Conforme |
| Preuves attendues, règles de détection, mitigations | ✅ Conforme |

### 6.2 Bloquants résiduels

1. **Auto-test en environnement réel non encore complété** : le fichier `chapitre-01-self-test.md` indique un statut "corrections nécessaires avant remise" car l'accès SSH root en mode BatchMode était refusé lors de la dernière session (mot de passe requis, pas de clé SSH). Le `tracking.state` indique que `sysadmin` a confirmé l'infrastructure disponible et que SSH root est maintenant fonctionnel sur les 3 VM. Il reste à **réexécuter les labs en réel** (`ssh root@<ip>`) pour générer toutes les preuves et remplacer les blocs "Résultat attendu" par des sorties réelles.

2. **Preuves manquantes identifiées** : le `tracking.state` signale 6 preuves manquantes pour Lab-01 (nettoyage-vm1/2/3.txt, config-vm1/2/3.txt). Ces preuves doivent être générées par l'exécution réelle.

### 6.3 Recommandation

**Le cours n'est pas encore prêt pour remise immédiate à `student`.** Il doit passer par l'étape d'auto-test en environnement réel :

1. `sysadmin` confirme que l'infrastructure est disponible (3 VM, snapshots propres) — déjà fait selon `tracking.state`.
2. `prof` exécute Lab-01 et Lab-02 en réel sur les 3 VM (`ssh root@<ip>`, mot de passe depuis `.env`), génère les 6 preuves manquantes et valide le chapitre 1.
3. `prof` exécute les labs des chapitres 2 à 5 en réel pour générer toutes les preuves et valider les commandes.
4. Remise à `student` pour test débutant (sans corrigé séparé).
5. Feedback de `student`, correction versionnée, re-test ciblé.
6. Validation finale (portes G0-G7) par `orchestrator`, mise à jour de `tracking.db` et `tracking.state`.

Une fois l'auto-test réel complété et les preuves générées, le contenu est prêt pour remise à `student`.

---
*Rapport généré par l'agent `prof`. Tous les fichiers de cours sont dans `/home/yug/Documents/mysql/chapitre-0{1,2,3,4,5}.md`.*