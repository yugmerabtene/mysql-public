# Rapport d'alignement — Chapitres 1 à 5 avec le syllabus (NDB-01 à NDB-31)

**Produit par :** agent `prof` — parcours « MySQL Cluster : Administration et exploitation »
**Source de vérité :** `syllabus.md` (tableau des opérations de référence, lignes 117-127)
**Cible infrastructure :** 3 VM sur `vboxnet0` 192.168.56.0/24 — VM 1 `gestion-sql` 192.168.56.10 (ndb_mgmd Id=1 + mysqld Id=4), VM 2 `stockage` 192.168.56.11 (ndbmtd Id=2 et Id=3), VM 3 `mysql-node3` 192.168.56.12 (mysqld Id=5).

---

## 1. Tableau de correspondance NDB-01 à NDB-31 → chapitres

| NDB | Intitulé (syllabus) | Module | Chapitre | Lab(s) | Statut |
|-----|---------------------|--------|----------|--------|--------|
| NDB-01 | Présentation des composants | 1.0 | Chapitre 1 | Lab-01 | Couvert |
| NDB-02 | Études de cas | 1.0 | Chapitre 1 | Lab-01 | Couvert |
| NDB-03 | Installation composants | 1.1 | Chapitre 1 | Lab-02 | Couvert |
| NDB-04 | Configuration initiale | 1.1 | Chapitre 1 | Lab-02 | Couvert |
| NDB-05 | Vérification d'intégrité | 1.1 | Chapitre 1 | Lab-02 | Couvert |
| NDB-06 | Moteur NDB | 2.0 | Chapitre 2 | Lab-03 | Couvert |
| NDB-07 | Types de nœuds | 2.0 | Chapitre 2 | Lab-03 | Couvert |
| NDB-08 | Dimensionnement résilience | 1.1 | Chapitre 1 | Lab-02 | Couvert |
| NDB-09 | Quorum et split-brain | 2.0 | Chapitre 2 | Lab-04 | Couvert |
| NDB-10 | Node groups | 2.0 | Chapitre 2 | Lab-04 | Couvert |
| NDB-11 | Configuration nœuds | 2.1 | Chapitre 2 | Lab-05 | Couvert |
| NDB-12 | Ajout/suppression nœuds | 2.1 | Chapitre 2 | Lab-05 | Couvert |
| NDB-13 | Surveillance état | 2.1 | Chapitre 2 | Lab-05 | Couvert |
| NDB-14 | Test de panne | 2.1 | Chapitre 2 | Lab-06 | Couvert |
| NDB-15 | Redémarrage rolling | 2.1 | Chapitre 2 | Lab-06 | Couvert |
| NDB-16 | Outils de supervision | 3.0 | Chapitre 3 | Lab-07 | Couvert |
| NDB-17 | Tâches de maintenance | 3.0 | Chapitre 3 | Lab-07 | Couvert |
| NDB-18 | Sauvegarde/restauration | 3.0 | Chapitre 3 | Lab-08 | Couvert |
| NDB-19 | Remplacement nœud défaillant | 3.0 | Chapitre 3 | Lab-08 | Couvert |
| NDB-20 | Installation agents MCM | 3.1 | Chapitre 3 | Lab-09 | Couvert |
| NDB-21 | Création clusters MCM | 3.1 | Chapitre 3 | Lab-09 | Couvert |
| NDB-22 | Gestion clusters MCM | 3.1 | Chapitre 3 | Lab-09 | Couvert |
| NDB-23 | Paramètres performance | 4.0 | Chapitre 4 | Lab-10 | Couvert |
| NDB-24 | Goulots d'étranglement | 4.0 | Chapitre 4 | Lab-10 | Couvert |
| NDB-25 | Sharding/partitionnement | 4.0 | Chapitre 4 | Lab-11 | Couvert |
| NDB-26 | Réplication inter-clusters | 4.1 | Chapitre 4 | Lab-13 (nouveau) | Ajouté, à tester |
| NDB-27 | Gestion des pannes | 4.1 | Chapitre 4 | Lab-14 (nouveau) | Ajouté, à tester |
| NDB-28 | Failover / failback | 4.1 | Chapitre 4 | Lab-14 (nouveau) | Ajouté, à tester |
| NDB-29 | Sécurité connexions | 5.0 | Chapitre 5 | Lab-12 | Couvert |
| NDB-30 | Sécurité des données | 5.0 | Chapitre 5 | Lab-12 | Couvert |
| NDB-31 | Sécurité des nœuds | 5.0 | Chapitre 5 | Lab-12 | Couvert |

**Total : 31 opérations sur 31 couvertes (100 %) après ajout du module 4.1.**

---

## 2. Écart identifié et comblé

**Avant l'ajout :** le chapitre 4 ne couvrait que NDB-23, NDB-24, NDB-25 (module 4.0 uniquement). Les opérations NDB-26, NDB-27, NDB-28 (module 4.1 — Gestion de la Réplication et de la Tolérance aux Pannes) n'étaient traitées dans aucun chapitre.

**Action réalisée :** ajout du module 4.1 au chapitre 4 (`chapitre-04.md`) avec deux labs au format canonique :

- **Lab-13 — Réplication entre clusters (NDB-26)** : déploiement d'un cluster de secours (Cluster B) sur VM 3 (gestion Id=10, stockage Id=20, SQL replica Id=6), activation du journal binaire sur le SQL source (Id=4, VM 1), création de l'utilisateur de réplication, configuration du canal (`CHANGE MASTER TO`, `START SLAVE`), insertion de données sur le site principal et vérification de leur propagation sur le site de secours (`Seconds_Behind_Master = 0`, données cohérentes).
- **Lab-14 — Simulation de panne, failover et failback (NDB-27, NDB-28)** : arrêt du nœud de stockage Id=2 (`ndb_mgm -e "2 STOP"`), observation des transitions `not connected` → `recovering` → `connected` via `ndb_mgm -e "SHOW"`, vérification de la continuité de service (failover), mesure du temps de basculement (objectif < 1 s), redémarrage du nœud et validation de la resynchronisation sans perte de données (failback).

**Contraintes de format respectées :**
- Titre `## Lab-XX — ...` (jamais numérotation `## 6. Lab-01`).
- Exactement 4 sections `###` par lab : `Énoncé / Contexte`, `Outils et commandes utilisées`, `Commande et laboratoire étape par étape`, `En conclusion`.
- Ordre d'étape : `**But**` → `**Machine**` → `**Prérequis**` → encart de localisation → commande → explication en liste → `**Résultat attendu**`.
- Encart de localisation : `> **Machine** : ... | **Terminal** : session SSH ouverte sur <hostname> | **Utilisateur** : root | **Répertoire** : ...`.
- Pas de section `Corrigé` séparée, pas de bloc `Changelog` dans le chapitre.
- Pas de références `preuves/` dans le corps du cours (présentes uniquement dans les étapes de lab, conformément à la règle de preuve d'exécution).
- Mot « port » / « portuaire » absent de la partie cours et vocabulaire (vérifié : aucune occurrence dans `chapitre-04.md`).
- Mode « déjà connecté en SSH » : commandes directes, pas de `ssh root@<ip> "cmd"`.
- Diagrammes Mermaid : 2 (Fig 4.3 réplication inter-clusters, Fig 4.4 cycle failover/failback), < 15 noeuds chacun, avec légende `**Fig X.Y** — Description`.

---

## 3. Confirmation de couverture de toutes les opérations NDB

Après ajout du module 4.1, **toutes les opérations NDB-01 à NDB-31 du syllabus sont couvertes** par les chapitres 1 à 5 :

- Chapitre 1 (Jour 1) : NDB-01, 02, 03, 04, 05, 08 (modules 1.0, 1.1) — 6 opérations.
- Chapitre 2 (Jour 2) : NDB-06, 07, 09, 10, 11, 12, 13, 14, 15 (modules 2.0, 2.1) — 9 opérations.
- Chapitre 3 (Jour 3) : NDB-16, 17, 18, 19, 20, 21, 22 (modules 3.0, 3.1) — 7 opérations.
- Chapitre 4 (Jour 4) : NDB-23, 24, 25 (module 4.0) + NDB-26, 27, 28 (module 4.1, ajouté) — 6 opérations.
- Chapitre 5 (Jour 5) : NDB-29, 30, 31 (module 5.0) — 3 opérations.

6 + 9 + 7 + 6 + 3 = 31 opérations = couverture complète du référentiel NDB-01 à NDB-31.

---

## 4. Recommandation : le cours est-il prêt pour le commit/push final ?

**NON. Le cours n'est pas encore prêt pour le commit/push final.**

### Motifs

1. **Pas d'auto-test en réel sur les 3 VM.** D'après `tracking.state`, les chapitres 1 à 5 sont rédigés et au format canonique, mais **pas testés en réel sur les 3 VM**. Les blocs `**Résultat attendu**` contiennent encore des sorties attendues (placeholders), pas des sorties réelles extraites d'exécutions de laboratoire avec preuves horodatées (`# date:`, `# cmd:`, `# rc=`).

2. **Le nouveau module 4.1 n'a pas été testé.** Lab-13 et Lab-14 viennent d'être ajoutés ; ils n'ont jamais été exécutés sur les 3 VM (notamment le déploiement d'un second cluster sur VM 3, qui sollicite 1 Go de RAM et doit être vérifié).

3. **Statut bloqué.** `tracking.state` indique `statut: blocked` et `prochaine_action: (1) prof execute Lab-01 et Lab-02 en reel sur les 3 VM ... puis valide les chapitres 2-5`.

### Étapes à suivre avant tout commit/push

1. `sysadmin` confirme que l'infrastructure pour les modules est disponible (3 VM, réseau vboxnet0, snapshots propres `propre-avant-lab`, SSH root fonctionnel sur les 3 VM).
2. `prof` exécute **Lab-01 et Lab-02 en réel sur les 3 VM**, génère les preuves dans `preuves/ch1-lab1/` et `preuves/ch1-lab2/`, et remplace les blocs `**Résultat attendu**` par des sorties réelles.
3. `prof` valide les chapitres 2 à 5 (auto-test cible si nécessaire).
4. `prof` auto-teste le **module 4.1 (Lab-13, Lab-14) en réel sur les 3 VM** et remplace les résultats attendus par des sorties réelles.
5. Remise à `student` pour test débutant (sans corrigé séparé).
6. Feedback de `student`, qualification (blocker / major / minor / suggestion), correction versionnée, re-test ciblé si le déroulé change.
7. Validation finale (portes G0–G7) par `orchestrator`, mise à jour de `tracking.db` et de `tracking.state`.
8. **Uniquement alors** : commit `mise à jour` puis push vers le dépôt distant.

### Contraintes respectées dans ce rapport

- Aucun commit ni push n'a été effectué.
- Aucun secret n'est affiché en clair (le `.env` n'est pas lu ni exposé).
- Toutes les commandes sont conçues pour s'exécuter sur les VM uniquement, jamais sur l'hôte.
- Aucune VM n'est réinstallée, recréée, supprimée ou réinitialisée.
