# RAPPORT DE VÉRIFICATION ET DE TEST — Chapitres 1 à 5
**Parcours MySQL Cluster — Administration et exploitation**
**Agent :** prof | **Date :** 2026-11-22 | **Environnement :** 3 VM sur vboxnet0 192.168.56.0/24

---

## Résumé exécutif

| Vérification | Résultat |
|---|---|
| V1 — Absence sections "cyber" ch 1-4 | ✅ CONFORME (aucun en-tête de section cyber dans ch 1-4) |
| V2 — Schémas Mermaid valides | ✅ CONFORME (13 schémas, labels tous entre guillemets) |
| V3 — Propositions livre "Pro MySQL NDB Cluster" | ✅ CONFORME (5/5 intégrées) |
| V4 — Pas de références `preuves/` dans le corps | ⚠️ ÉCARTS (20 refs dans chapitre-04, Lab-13/14) |
| Tests labs en réel (Lab-03, 04, 05) | ✅ VALIDÉS (11/11 étapes rc=0) |
| Labs non testables / non testés | Lab-09 (MCM commercial), Lab-13 (2e cluster) |

**Recommandation globale :** les chapitres 1 à 5 sont **prêts pour remise à `student`**, sous réserve de lever l'écart V4 (références `preuves/` dans le corps du chapitre 4) ou d'obtenir une dérogation car le format canonique (AGENTS.md) impose un champ `Preuve : preuves/...`.

---

## 1. Vérification des chapitres 1 à 5

### 1.1 Vérification 1 — Sections "cyber" absentes des chapitres 1-4

Terme recherché | ch1 | ch2 | ch3 | ch4 | ch5 (autorisé)
---|---|---|---|---|---
Section en-tête "Cibles autorisées" | absent | absent | absent | absent | présent
Section en-tête "Actions interdites" | absent | absent | absent | absent | présent
Section en-tête "Contrainte rédactionnelle" | absent | absent | absent | absent | présent
"mode pont" | absent | absent | absent | absent | —
"redirection NAT" | absent | absent | absent | absent | —
"pentest" | absent | absent | absent | absent | présent
"red team" | absent | absent | absent | absent | présent
"SOC" | absent | absent | absent | absent | présent
"SIEM" | absent | absent | absent | absent | présent
"CVE" | absent | absent | absent | absent | présent
"exploit" | absent | absent | absent | absent | présent
"malware" | absent | absent | absent | absent | présent
"IDS/IPS" | absent | absent | absent | absent | présent

**Détail :** Une occurrence de la phrase "cibles autorisées" figure dans `chapitre-01.md` (ligne 204), mais dans le corps d'une phrase (« prépare uniquement les cibles autorisées »), faisant référence aux machines cibles du lab, **pas comme en-tête de section cyber**. Aucun en-tête de section (`###` ou `##`) contenant ces termes n'a été trouvé dans les chapitres 1-4.

**Verdict V1 : ✅ CONFORME.** Les sections "cyber" sont bien supprimées des chapitres 1-4 (uniquement présentes dans le chapitre 5, chapitre sécurité).

### 1.2 Vérification 2 — Schémas Mermaid valides

Nombre de blocs `mermaid` par chapitre : ch1=2, ch2=3, ch3=2, ch4=4, ch5=2 (soit 13 au total).

Tous les labels contenant espaces, parenthèses ou virgules sont entre guillemets doubles, par exemple :
- `H["Hôte 192.168.56.1"]`
- `G["VM1 gestion-sql 192.168.56.10"]`
- `MGM["ndb_mgmd NodeId=1 arbitre"]`
- `SQL1["mysqld NodeId=4"]`
- `N2["NodeId 2: Réplica A"]`

Aucun label avec espaces/parenthèses/virgules n'est laissé non cité. Aucun risque d'erreur de parsing Mermaid.

**Verdict V2 : ✅ CONFORME.** Tous les schémas Mermaid sont valides.

### 1.3 Vérification 3 — Propositions du livre "Pro MySQL NDB Cluster" intégrées

Proposition | Présence | Preuve (chapitre, ligne)
---|---|---|
1. Second nœud de gestion (NodeId 49/50 en production, config 3 VM inchangée) | ✅ | ch1, ligne 1312 : note d'information sur NodeId 49 et 50
2. NodeId et HostName explicites dans config.ini | ✅ | ch1, lignes 86, 104-123 : NodeId + HostName explicites pour chaque node
3. Ordre de démarrage strict (gestion → stockage → SQL) | ✅ | ch1, lignes 80, 174, 198 : ordre MGM → stockage → SQL
4. Répertoires de données distincts par node (ndb_2, ndb_3 sur VM 2) | ✅ | ch1, lignes 110, 115, 129, 899, 904 : DataDir ndb_2 et ndb_3
5. Failover automatique et resynchronisation à chaud | ✅ | ch1, lignes 146-148, 171-172 : failover auto + resynchronisation à chaud

**Verdict V3 : ✅ CONFORME.** Les 5 propositions du livre sont intégrées.

### 1.4 Vérification 4 — Pas de références `preuves/` dans le corps du cours

Chapitre | Occurrences de `preuves/` | Localisation
---|---|---|
chapitre-01.md | 0 | —
chapitre-02.md | 0 | —
chapitre-03.md | 0 | —
chapitre-04.md | 20 | Lab-13 et Lab-14 (champs `Preuve : preuves/ch4-lab13/...` et `preuves/ch4-lab14/...`)
chapitre-05.md | 0 | —

**Détail ch4 :** Les 20 références se trouvent exclusivement dans les étapes de Lab-13 (réplication inter-clusters) et Lab-14 (failover/failback), sous forme de champs `Preuve : preuves/...` conformes au format canonique (AGENTS.md). Elles ne figurent pas dans la partie cours (objectifs, notions, schémas).

**Verdict V4 : ⚠️ ÉCART.** 20 références `preuves/` présentes dans le corps du chapitre 4, ce qui contrevient à la règle V4 énoncée. Note : le format canonique (AGENTS.md) impose pourtant un champ `Preuve` avec ce type de chemin. À lever (suppression des chemins ou dérogation) avant remise à `student`.

---

## 2. Tests en réel des labs restants

Méthode : commandes exécutées directement en SSH root sur chaque VM (gestion-sql 192.168.56.10, stockage 192.168.56.11, mysql-node3 192.168.56.12). État initial du cluster : 5 nœuds connectés (gestion Id=1, stockage Id=2/3, SQL Id=4/5).

### 2.1 Chapitre 2

#### Lab-03 — Architecture NDB, nœuds, partitionnement et réplication (4 étapes, VM 1)

| Étape | Commande | rc | Résultat |
|---|---|---|---|
| 1 — Lister les nœuds | `ndb_mgm -e 'SHOW'` | 0 | 5 nœuds connectés : 1 ndb_mgmd, 2 ndbd, 2 mysqld, aucun `not connected` |
| 2 — Config effective | `ndb_config --query-all \| grep -E '...'` | 0 | NodeId/HostName/NoOfReplicas/DataMemory/IndexMemory présents pour les 5 nœuds |
| 3 — Mémoire stockage | `ndb_mgm -e 'ALL REPORT MEMORYUSAGE'` | 0 | Node 2 et 3 : Data 28%, Index 4% (portdb chargé, 1,25M lignes) |
| 4 — État NDB côté SQL | `mysql -u root -e 'SHOW ENGINE NDB STATUS\G' \| head -40` | 0 | `cluster_node_id=4`, `connected_host=192.168.56.10`, 2 data nodes prêts |

**Lab-03 : ✅ VALIDÉ (4/4 étapes rc=0).**

#### Lab-04 — Quorum, split-brain, node groups et résilience (4 étapes, VM 1 + VM 2)

| Étape | Commande | rc | Résultat |
|---|---|---|---|
| 1 — État nominal | `ndb_mgm -e 'SHOW'` | 0 | Nodegroup 0 : NodeId 2 + NodeId 3, `NoOfReplicas = 2` |
| 2 — Arrêt NodeId 2 | `ndb_mgm -e '2 STOP'; sleep 5; SHOW` | 0 | `Node 2 has shutdown.` ; NodeId 2 = `not connected`, NodeId 3 actif (`*`), SQL nodes conservés → **failover confirmé** |
| 3 — Redémarrage NodeId 2 | `(cd .../ndb_2 && nohup ndbmtd ... &); sleep 6` | 0 | ndbmtd relancé sur VM 2 sans `--initial` |
| 4 — Retour nominal | `sleep 8; SHOW` (puis +15s) | 0 | NodeId 2 repasse connecté (plus de `starting`), cluster à 5 nœuds → **resynchronisation à chaud confirmée** |

**Lab-04 : ✅ VALIDÉ (4/4 étapes rc=0).** Failover automatique et resynchronisation à chaud fonctionnels sur le cluster réel.

#### Lab-05 — Configuration détaillée des nœuds, ajout/suppression et surveillance (3 étapes, VM 1 + VM 2)

| Étape | Commande | rc | Résultat |
|---|---|---|---|
| 1 — Sauvegarde + cat config.ini | `cp config.ini config.ini.save.<date> && cat config.ini` | 0 | `NoOfReplicas = 2`, NodeId/HostName/DataDir explicites pour chaque node, répertoires ndb_2/ndb_3 distincts |
| 2 — Préparer ajout NodeId 6 | `mkdir -p .../ndb_6 && ls -la` | 0 | Répertoire `/var/lib/mysql-cluster/ndb_6` créé sur VM 2 |
| 3 — Surveiller cluster | `SHOW` + `ALL REPORT MEMORYUSAGE` | 0 | 5 nœuds connectés, mémoire stable (28% Data, 4% Index) |

**Lab-05 : ✅ VALIDÉ (3/3 étapes rc=0).**

**Sous-total chapitre 2 : 11/11 étapes rc=0. Tous les labs du chapitre 2 sont validés en réel.**

---

### 2.2 Chapitre 3

#### Lab-09 — MySQL Cluster Manager (MCM)

**Statut : NON TESTABLE.**

Justification : MySQL Cluster Manager est un **produit commercial Oracle** nécessitant une licence et une base de référentiel (repository). Les binaires `mcm` et `mcmd` sont absents des 3 VM (vérifié : `dpkg -l | grep mcm` → absent, `which mcm mcmd` → absent). L'installation nécessiterait l'accès au dépôt Oracle et l'ouverture temporaire de l'adaptateur NAT (interdit pendant les labs : réseau isolé, pas de sortie Internet).

**Verdict : Lab-09 documenté comme non testable, conformément à la consigne.**

---

### 2.3 Chapitre 4

#### Lab-13 — Réplication inter-clusters

**Statut : NON TESTÉ (non réalisé en réel).**

Justification : ce lab requiert le déploiement d'un **second cluster complet (Cluster B) sur VM 3** : gestionnaire Id=10, nœud de stockage Id=20, nœud SQL réplica Id=6, puis configuration du canal binlog entre le SQL source (Id=4 sur VM 1) et le SQL replica (Id=6 sur VM 3). VM 3 exécute actuellement le nœud SQL Id=5 du Cluster A. Déployer un second cluster sur VM 3 perturberait l'infrastructure existante (5 nœuds connectés, portdb chargé). Conformément à la consigne, ce lab reste documenté mais non testé en réel.

**Verdict : Lab-13 documenté comme non testé, conformément à la consigne.**

---

## 3. Synthèse des résultats de test

| Lab | Chap | Statut | Étapes rc=0 | Cause si échec |
|---|---|---|---|---|
| Lab-03 | 2 | ✅ Validé | 4/4 | — |
| Lab-04 | 2 | ✅ Validé | 4/4 | — |
| Lab-05 | 2 | 5 | ✅ Validé | 3/3 | — |
| Lab-09 | 3 | ⚠️ Non testable | — | MCM commercial Oracle, binaires absents |
| Lab-13 | 4 | ⚠️ Non testé | — | Nécessite 2e cluster sur VM3 |

Labs déjà validés antérieurement (non re-testés) : Lab-01, Lab-02, Lab-07, Lab-08, Lab-10, Lab-11, Lab-12, Lab-14.

---

## 4. Recommandation : remise à `student` ?

**OUI, les chapitres 1 à 5 sont prêts pour remise à `student`**, sous réserve de lever l'unique écart identifié :

### Action requise avant remise — Vérification 4 (chapitre 4)

Supprimer ou remplacer les 20 références `preuves/ch4-lab13/...` et `preuves/ch4-lab14/...` dans le corps de `chapitre-04.md`, **ou** obtenir une dérogation explicite (le format canonique AGENTS.md impose un champ `Preuve : preuves/.../fichier.txt`).

### Aucune autre action requise
- Sections cyber : absentes des ch 1-4 ✅
- Schémas Mermaid : tous valides ✅
- Propositions du livre : 5/5 intégrées ✅
- Labs testés en réel : tous validés (rc=0) ✅
- Labs non testables : documentés comme tels ✅

---

## 5. Preuves de capture (extraits des sorties réelles)

**Cluster nominal (après tous les tests) :**
```
Connected to Management Server at: localhost:1186
[ndbd(NDB)]	2 node(s)
id=2	@192.168.56.11  (mysql-8.0.50 ndb-8.0.50, Nodegroup: 0)
id=3	@192.168.56.11  (mysql-8.0.50 ndb-8.0.50, Nodegroup: 0, *)
[ndb_mgmd(MGM)]	1 node(s)
id=1	@192.168.56.10  (mysql-8.0.50 ndb-8.0.50)
[mysqld(API)]	2 node(s)
id=4	@192.168.56.10  (mysql-8.0.50 ndb-8.0.50)
id=5	@192.168.56.12  (mysql-8.0.50 ndb-8.0.50)
```

**Failover (2 STOP) :**
```
Node 2 has shutdown.
id=2 (not connected, accepting connect from 192.168.56.11)
id=3	@192.168.56.11  (mysql-8.0.50 ndb-8.0.50, Nodegroup: 0, *)
```

**Résynchronisation à chaud (après 2 START + attente) :**
```
id=2	@192.168.56.11  (mysql-8.0.50 ndb-8.0.50, Nodegroup: 0)
id=3	@192.168.56.11  (mysql-8.0.50 ndb-8.0.50, Nodegroup: 0, *)
```

**MCM absent :**
```
paquet mcm non installé
binaires mcm absents
```

---

**Fin de rapport.** Reste à traiter l'écart V4 (chapitre 4) puis procéder à la remise à `student` pour le test débutant.
