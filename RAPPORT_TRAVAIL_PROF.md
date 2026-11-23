# Rapport de travail — Agent `prof` — Parcours MySQL Cluster

**Date** : 2026-11-22 | **Auteur** : agent `prof` | **Cible** : `orchestrator` | **Statut** : travaux terminés, prêts pour relecture

## 1. Contexte et état de départ

L'infrastructure 3 VM est opérationnelle (confirmée par `sysadmin`, SSH root fonctionnel) :
| VM | Hostname | IP | Rôle | SSH |
|---|---|---|---|---|
| VM 1 | gestion-sql | 192.168.56.10/24 | Nœud de gestion (`ndb_mgmd`) + nœud SQL (`mysqld`, NodeId=4) | OK |
| VM 2 | stockage | 192.168.56.11/24 | Deux nœuds de stockage `ndbmtd` (NodeId=2 et NodeId=3) | OK |
| VM 3 | mysql-node3 | 192.168.56.12/24 | Second nœud SQL (`mysqld`, NodeId=5) | OK |

- Réseau : vboxnet0 192.168.56.0/24, DHCP off, pas d'Internet pendant les labs.
- Snapshots `propre-avant-lab` présents sur chaque VM.
- Chapitre 1 déjà rédigé, mais **non testé en réel** (6 preuves de nettoyage manquantes, blocs "Résultat attendu" anticipés, pas de sorties réelles).

Toutes les exécutions ont été réalisées via `ssh root@<ip>` (mot de passe depuis `.env`, jamais affiché en clair). Aucune VM n'a été réinstallée (règle absolue respectée). Aucun secret n'a été affiché ni commité.

## 2. Partie A — Corrections apportées au chapitre 1

Le fichier `/home/yug/Documents/mysql/chapitre-01.md` a été relu entièrement et corrigé :

### Corrections structurelles
1. **Suppression de la section "Vérification préalable"** (anciennes lignes 152-165) qui référençait des fichiers de preuve (`preuves/ch1-lab1/*.txt`) dans le corps du cours. Les preuves restent générées dans les étapes de lab, mais n'apparaissent plus comme contenu de cours.
2. **Suppression de la référence aux fichiers de preuve** en fin de section "Ressources et références" (`preuves/ch1-lab1/*.txt` et `preuves/ch1-lab2/*.txt`).
3. **Suppression d'un doublon d'explication** dans Lab-01 étape 1 (la ligne `- ssh root@192.168.56.10 "..." : exécute la commande de nettoyage sur VM 1 directement en root.` était dupliquée).
4. **Remplacement du résultat attendu incohérent de Lab-01 étape 8** qui mélangeait succès et `Permission denied (publickey,password)` par la sortie réelle (3 pings 4/4 OK, 3 SSH root OK `gestion-sql`/`stockage`/`mysql-node3`).

### Vérifications de conformité
- Format canonique respecté : `## Lab-XX — Titre` puis exactement 4 sections `###` (`Énoncé / Contexte`, `Outils et commandes utilisées`, `Commande et laboratoire étape par étape`, `En conclusion`).
- Ordre des étapes : `**But**` → `**Machine**` → `**Prérequis**` → encart de localisation → commande → explication en liste → `**Résultat attendu**` → `**Preuve** :`.
- Pas de section `Corrigé` séparée, pas de bloc `Changelog` dans le chapitre.
- Le mot "port"/"portuaire" n'apparaît pas dans la partie cours ni le vocabulaire (uniquement dans la consigne de rédaction ligne 16, et dans les étapes de lab via les références techniques 1186/3306, ce qui est autorisé).
- Aucun caractère d'un autre alphabet ni mot intrus détecté.

### Ajout : étapes de résilience (Lab-02)
Ajout des étapes 12, 13 et 14 au Lab-02 pour couvrir le test de résilience demandé par la mission (arrêt d'un `ndbmtd`, failover, redémarrage, resynchronisation), avec leurs commandes, explications et sorties réelles.

## 3. Partie B — Tests réels Lab-01 et Lab-02 sur les 3 VM

Tous les labs ont été exécutés en réel sur les 3 VM. Toutes les preuves sont générées avec les en-têtes obligatoires `# date:`, `# cmd:`, `# rc=`. Tous les codes retour sont `rc=0`.

### Lab-01 — Mise en place manuelle des 3 VM

| Étape | Action | Preuve générée | rc |
|---|---|---|---|
| 1 | Nettoyer VM 1 | `preuves/ch1-lab1/nettoyage-vm1.txt` | 0 |
| 2 | Configurer VM 1 (hostname, IP statique, SSH) | `preuves/ch1-lab1/config-vm1.txt` | 0 |
| 3 | Nettoyer VM 2 | `preuves/ch1-lab1/nettoyage-vm2.txt` | 0 |
| 4 | Configurer VM 2 (hostname, IP statique, SSH) | `preuves/ch1-lab1/config-vm2.txt` | 0 |
| 5 | Nettoyer VM 3 | `preuves/ch1-lab1/nettoyage-vm3.txt` | 0 |
| 6 | Configurer VM 3 (hostname, IP statique, SSH) | `preuves/ch1-lab1/config-vm3.txt` | 0 |
| 7 | Snapshots propres (VBoxManage) | `preuves/ch1-lab1/snapshot-UbuntuServer-01/02/03.txt` | 0 |
| 8 | Connectivité ping + SSH root depuis l'hôte | `preuves/ch1-lab1/ping-vm1/2/3.txt`, `ssh-root-vm1/2/3.txt` | 0 |

Résultat : les 6 preuves manquantes signalées dans `tracking.state` (nettoyage-vm1/2/3, config-vm1/2/3) sont générées. Le `propre-avant-lab` est présent sur les 3 VM (marqué `*` dans `VBoxManage snapshot list`). `ping` et `ssh root@` fonctionnent depuis l'hôte vers les 3 VM.

### Lab-02 — Installation de MySQL Cluster sur les 3 VM

| Étape | Action | Preuve générée | rc |
|---|---|---|---|
| 1 | Vérifier paquets VM 1 (gestion+SQL) | `preuves/ch1-lab2/dpkg-ndb-gestion-sql.txt` | 0 |
| 2 | Vérifier paquets VM 2 (stockage) | `preuves/ch1-lab2/dpkg-ndb-stockage.txt` | 0 |
| 3 | Vérifier paquets VM 3 (SQL) | `preuves/ch1-lab2/dpkg-ndb-mysql-node3.txt` | 0 |
| — | Installation composants VM 1 | `preuves/ch1-lab2/install-vm1-gestion-sql.txt` | 0 |
| — | Correction mysql-common VM 1 | `preuves/ch1-lab2/fix-mysqlcommon-vm1.txt` | 0 |
| — | Installation composants VM 2 | `preuves/ch1-lab2/install-vm2-stockage.txt` | 0 |
| — | Installation composants VM 3 | `preuves/ch1-lab2/install-vm3-sql.txt` | 0 |
| 4 | Rédiger et installer `config.ini` (NoOfReplicas=2) | `preuves/ch1-lab2/config-ini.txt`, `config-ini-installe.txt` | 0 |
| 5 | Créer répertoires ndb_2, ndb_3 sur VM 2 | `preuves/ch1-lab2/repertoires-donnees-vm2.txt` | 0 |
| 6 | Démarrer ndb_mgmd sur VM 1 | `preuves/ch1-lab2/ndb-mgmd-start.txt` | 0 |
| 7 | Démarrer ndbmtd ×2 sur VM 2 | `preuves/ch1-lab2/ndbmtd-start.txt` | 0 |
| 8 | Démarrer mysqld NodeId 4 sur VM 1 | `preuves/ch1-lab2/mysqld-start-vm1.txt` | 0 |
| 9 | Démarrer mysqld NodeId 5 sur VM 3 | `preuves/ch1-lab2/mysqld-start-vm3.txt` | 0 |
| 10 | Vérifier `SHOW` (5 nœuds connectés) | `preuves/ch1-lab2/ndb-show.txt` | 0 |
| 11 | Interroger `ndb_config --query-all` | `preuves/ch1-lab2/ndb-config.txt` | 0 |
| 12 | Arrêt NodeId 2 + failover | `preuves/ch1-lab2/resilience-stop-node2.txt` | 0 |
| 13 | Redémarrage manuel NodeId 2 | `preuves/ch1-lab2/resilience-restart-node2-manuel.txt` | 0 |
| 14 | SHOW final (réintégration) | `preuves/ch1-lab2/resilience-final-show.txt`, `resilience-final-show2.txt` | 0 |

Résultat clé : `ndb_mgm -e "SHOW"` affiche les 5 nœuds connectés (id=1 mgmd, id=2 et 3 ndbd, id=4 et 5 mysqld) sans état `not connected`. `ndb_config` confirme `NoOfReplicas = 2`. Le test de résilience confirme : arrêt du NodeId 2 → `not connected`, NodeId 3 reste actif (`*`), service continu ; redémarrage manuel du NodeId 2 → resynchronisation depuis le NodeId 3 → retour à l'état nominal.

### Preuves supplémentaires chapitres 2-5 (exécution réelle partielle)
- `preuves/ch2-lab3/memory-usage.txt` (rc=0) : `ALL REPORT MEMORYUSAGE` — Node 2 et 3, Data usage 0%, Index usage 0%.
- `preuves/ch3-lab8/start-backup.txt` (rc=0) : `START BACKUP` — Backup 1 complété, StartGCP 173 StopGCP 176, #Records: 9, Data: 2112 bytes.

## 4. Partie C — Chapitres 2, 3, 4, 5 rédigés

Les fichiers suivants ont été créés au format canonique (titre `# Chapitre X`, labs `## Lab-XX`, 4 sections `###` par lab, pas de corrigé séparé, pas de changelog, 2 diagrammes Mermaid minimum par chapitre, cartographie NDB-nn, erreurs fréquentes Partie D intégrée) :

| Chapitre | Fichier | Labs | Opérations NDB couvertes |
|---|---|---|---|
| 2 — Architecture et Administration | `chapitre-02.md` | Lab-03, Lab-04, Lab-05, Lab-06 | NDB-06, 07, 09, 10, 11, 12, 13, 14, 15 |
| 3 — Supervision et Maintenance | `chapitre-03.md` | Lab-07, Lab-08, Lab-09 | NDB-16, 17, 18, 19, 20, 21, 22 |
| 4 — Optimisation et Scalabilité | `chapitre-04.md` | Lab-10, Lab-11 | NDB-23, 24, 25 |
| 5 — Sécuriser MySQL Cluster | `chapitre-05.md` | Lab-12 | NDB-29, 30, 31 |

Chaque chapitre contient : objectifs, avertissement/périmètre, durée, prérequis, vocabulaire, introduction avec 2 diagrammes Mermaid (légendés `**Fig X.Y** — ...`), modèle de menace, cartographie des opérations, labs au format canonique avec commandes réelles, explications décomposées, résultats attendus (réels pour les commandes exécutées, plausibles cohérents pour le reste), erreurs fréquentes et corrections (Partie D intégrée), synthèse, ressources et références.

Le mot "port"/"portuaire" n'est pas employé dans la partie cours ni le vocabulaire des chapitres 2-5 (uniquement dans la consigne de rédaction ligne 16).

## 5. Partie D — Erreurs récurrentes et corrections

Intégrée dans chaque chapitre (section "Erreurs fréquentes et corrections détaillées") avec 5 catégories :
- Erreurs de conception (NoOfReplicas insuffisant, DataMemory/IndexMemory sous-dimensionnés, node group unique sur une seule VM, pas de nœud de gestion de secours)
- Erreurs d'architecture (single point of failure, pas de nœud de gestion de secours, pas de redondance physique, tous les nœuds sur une seule VM)
- Erreurs de configuration (ndb_mgmd adresse déjà utilisée, nœud not connected, mysqld sans --ndbcluster, ordre de démarrage incorrect, IP non persistante)
- Erreurs sur gros volumes (table is full, swap prolongé, latence de commit élevée, saturation réseau, partitionnement inadapté)

Pour chaque erreur : symptôme, cause probable, correction.

## 6. Recommandation : le cours est-il prêt pour remise à `student` ?

**Oui, avec réserve mineure.**

### Ce qui est validé (prêt)
- Chapitre 1 : entièrement corrigé, labs Lab-01 et Lab-02 testés en réel sur les 3 VM, toutes les preuves générées (rc=0), sorties réelles intégrées dans tous les blocs `**Résultat attendu**`.
- Chapitres 2, 3, 4, 5 : rédigés au format canonique, alignés sur le syllabus (NDB-01 à NDB-31), avec modèles de menace, diagrammes Mermaid, erreurs fréquentes et mitigations.
- Preuves réelles disponibles pour les commandes critiques (SHOW, mémoire, sauvegarde, panne/failover).

### Réserve mineure (auto-test ciblé recommandé avant remise)
Les blocs `**Résultat attendu**` des chapitres 2-5 qui n'ont pas été exécutés en réel contiennent des sorties plausibles cohérentes (non des sorties réelles extraites d'exécution). Conformément à la mission ("résultats attendus réels (ou plausibles si non exécutés)"), cela est acceptable, mais un auto-test ciblé sur un sous-ensemble des labs 2-5 permettrait de remplacer ces sorties par des sorties réelles si `student` doit comparer exactement sa sortie.

### Prochaine action recommandée
Remettre les chapitres 1 à 5 à `student` pour le test débutant, puis `orchestrator` valide les portes G0–G7 et met à jour `tracking.db` / `tracking.state`.

## 7. Fichiers produits et modifiés

**Modifiés :**
- `chapitre-01.md` — corrections structurelles + sorties réelles + étapes de résilience.

**Créés :**
- `chapitre-02.md`, `chapitre-03.md`, `chapitre-04.md`, `chapitre-05.md` — cours complets au format canonique.

**Preuves générées (toutes avec `# date:`, `# cmd:`, `# rc=`, rc=0) :**
- `preuves/ch1-lab1/` : 15 fichiers (nettoyage ×3, config ×3, snapshot ×3, ping ×3, ssh-root ×3).
- `preuves/ch1-lab2/` : 21 fichiers (dpkg ×3, install ×4, config-ini ×2, répertoires, ndb-mgmd, ndbmtd, mysqld ×2, ndb-show, ndb-config, résilience ×5).
- `preuves/ch2-lab3/memory-usage.txt` (réel).
- `preuves/ch3-lab8/start-backup.txt` (réel).

**Non commité, non pushé** (conformément à la consigne).
