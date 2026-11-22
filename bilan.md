# Bilan d'analyse — Chapitres 1 à 5 vs syllabus MySQL Cluster

**Auteur** : agent `prof` — parcours « MySQL Cluster : Administration et exploitation »
**Cible** : `chapitre-01.md` à `chapitre-05.md` par rapport à `syllabus.md` (source de vérité)
**Date** : 2026-11-22
**Contraintes respectées** : aucun chapitre modifié, aucun fichier `.bak`/`.pre-fix` touché, seul `bilan.md` est ajouté.

---

## A. Vue d'ensemble

### A.1 Couverture structurelle

| Élément | Valeur constatée | Référence syllabus | Écart |
|---|---|---|---|
| Nombre de chapitres | 5 (chapitre-01 à chapitre-05) | 5 jours (Jour 1 à Jour 5) | Aucun |
| Modules couvés | 1.0, 1.1, 2.0, 2.1, 3.0, 3.1, 4.0, 4.1, 5.0 | 9 modules | Aucun module manquant |
| Nombre de labs définis | 14 (Lab-01 à Lab-14) | 9 travaux pratiques de module (un par module) | 5 labs supplémentaires (découpage et prépa infra) |
| Durée déclarée | J1=6h, J2=12h, J3=9h, J4=12h, J5=6h (total 45h) | J1=6h, J2=6h, J3=6h, J4=6h, J5=6h (total 30h) | +15h déclarées sur J2, J3, J4 |
| Opérations NDB déclarées | NDB-01 à NDB-31 (31/31) | NDB-01 à NDB-31 (31) | 100 % sur le papier (voir A.2) |
| VMs utilisées | 3 (192.168.56.10, .11, .12) | Maximum 3, idéalement 2 | Conforme au maximum, pas à l'idéal |
| Réseau | vboxnet0 192.168.56.0/24, DHCP off | Idem | Conforme |

### A.2 Taux de couverture des opérations NDB (NDB-01 à NDB-31)

| ID | Opération | Module syllabus | Lab chapitre | Couverture déclarée | Couverture effective constatée |
|---|---|---|---|---|---|
| NDB-01 | Présentation des composants | 1.0 | Lab-01 / Lab-02 | Oui | Oui (cours + SHOW) |
| NDB-02 | Études de cas | 1.0 | Lab-01 / Lab-02 | Oui (texte) | Partielle (pas de lab dédié « exploration composants / études de cas ») |
| NDB-03 | Installation composants | 1.1 | Lab-02 | Oui | Oui (validé en réel) |
| NDB-04 | Configuration initiale | 1.1 | Lab-02 | Oui | Oui (config.ini) |
| NDB-05 | Vérification intégrité | 1.1 | Lab-02 | Oui | Oui (SHOW) |
| NDB-08 | Dimensionnement résilience | 1.1 | Lab-02 | Oui | Oui (NoOfReplicas=2) |
| NDB-06 | Moteur NDB | 2.0 | Lab-03 | Oui | Oui |
| NDB-07 | Types de nœuds | 2.0 | Lab-03 | Oui | Oui |
| NDB-09 | Quorum et split-brain | 2.0 | Lab-04 | Oui | Oui |
| NDB-10 | Node groups | 2.0 | Lab-04 | Oui | Oui |
| NDB-11 | Configuration nœuds | 2.1 | Lab-05 | Oui | Oui (config.ini, sauvegarde) |
| NDB-12 | Ajout/suppression nœuds | 2.1 | Lab-05 | Oui | **Incomplète** (mkdir ndb_6 seulement, aucun nœud ajouté/démarré/vérifié) |
| NDB-13 | Surveillance état | 2.1 | Lab-05 | Oui | Oui (SHOW + mémoire) |
| NDB-14 | Test de panne | 2.1 | Lab-04 / Lab-06 | Oui | Oui |
| NDB-15 | Redémarrage rolling | 2.1 | Lab-06 | Oui | Oui (nœud SQL) |
| NDB-16 | Outils de supervision | 3.0 | Lab-07 | Oui | Oui |
| NDB-17 | Tâches maintenance | 3.0 | Lab-07 | Oui | Oui |
| NDB-18 | Sauvegarde/restauration | 3.0 | Lab-08 | Oui | Oui |
| NDB-19 | Remplacement nœud défaillant | 3.0 | Lab-08 | Oui | **Partielle** (NodeId 6 démarré mais absent du SHOW final de vérification) |
| NDB-20 | Installation agents MCM | 3.1 | Lab-09 | Oui | **Nulle** (binaires absents, non testable) |
| NDB-21 | Création clusters MCM | 3.1 | Lab-09 | Oui | **Nulle** (binaires absents, non testable) |
| NDB-22 | Gestion clusters MCM | 3.1 | Lab-09 | Oui | **Nulle** (binaires absents, non testable) |
| NDB-23 | Paramètres performance | 4.0 | Lab-10 | Oui | Oui |
| NDB-24 | Goulots d'étranglement | 4.0 | Lab-10 | Oui | Oui |
| NDB-25 | Sharding/partitionnement | 4.0 | Lab-11 | Oui | Oui (préparation ndb_7/ndb_8, pas de démarrage de nouveaux nodes) |
| NDB-26 | Réplication inter-clusters | 4.1 | Lab-13 | Oui | **Incomplète** (nœud SQL replica Id=6 jamais démarré, mgmd sans config, non testable) |
| NDB-27 | Gestion pannes | 4.1 | Lab-14 | Oui | Oui |
| NDB-28 | Failover/failback | 4.1 | Lab-14 | Oui | Oui |
| NDB-29 | Sécurité connexions (TLS) | 5.0 | Lab-12 | Oui | Oui |
| NDB-30 | Sécurité données (moindre privilège) | 5.0 | Lab-12 | Oui | Oui |
| NDB-31 | Sécurité nœuds serveurs | 5.0 | Lab-12 | Oui | Oui |

**Taux déclarée** : 31/31 = 100 %.
**Taux effectif réalisable en l'état** : inférieur, car NDB-20/21/22 (MCM absent), NDB-12 (ajout non réalisé), NDB-19 (vérification absente), NDB-26 (lab incomplet) ne sont pas effectivement exécutables.

---

## B. Analyse chapitre par chapitre

### B.1 Chapitre 1 — Introduction et installation (modules 1.0 + 1.1)

| Point | Constat | Écart / anomalie |
|---|---|---|
| Objectif déclaré | Architecture NDB, 3 VM, config.ini, démarrage ordonné, vérification intégrité, résilience | Conforme syllabus 1.0 + 1.1 |
| Durée déclarée | 6 h (2 × 3 h) | Conforme (3 h + 3 h) |
| Labs | Lab-01 (prépa infra 3 VM), Lab-02 (installation cluster) | Lab-01 n'existe pas dans le syllabus (pré-requis infrastructure implicite) ; hors périmètre NDB mais nécessaire |
| Opérations NDB | NDB-01, 02, 03, 04, 05, 08 | Toutes les opérations du Jour 1 couvertes sur le papier |
| Incohérences | Syllabus ligne 11 : « deux nœuds de stockage (ndbmtd node-id 1 et 2) » sur VM 2 ; les chapitres utilisent NodeId 1 = gestion, NodeId 2 et 3 = stockage | **Contradiction syllabus ↔ chapitres sur les NodeId de stockage** |
| Problème commande | `apt-get update` / `apt-get install` (Lab-02 étape 4) alors que l'avertissement interdit l'accès Internet sur les nœuds pendant les labs | Contradiction avertissement vs étapes d'installation (résolu seulement au chapitre 5 par un adaptateur NAT temporaire) |
| Résultats attendus | Multiples blocs `# rc=0` sans sortie réelle ; pas d'en-têtes `# date:` / `# cmd:` / `# rc=` dans les preuves | Non-conforme à la règle 7 du format canonique (preuves réelles avec en-têtes) |
| Mermaid | Fig 1.1 et 1.2 : étiquettes guillemetées, conformes | Aucun défaut |

**Verdict** : chapitre cohérent, mais Lab-01 est une prépa infra hors syllabus et la contradiction NodeId (syllabus 1 et 2 vs chapitres 2 et 3 pour le stockage) doit être tranchée.

### B.2 Chapitre 2 — Architecture et Administration (modules 2.0 + 2.1)

| Point | Constat | Écart / anomalie |
|---|---|---|
| Objectif déclaré | Architecture NDB détaillée, config nœuds, ajout/suppression, surveillance, panne, rolling restart | Conforme syllabus 2.0 + 2.1 |
| Durée déclarée | 12 h (4 × 3 h) | **Non conforme** : syllabus 2.0 (3 h) + 2.1 (3 h) = 6 h, le chapitre déclare le double |
| Labs | Lab-03, 04, 05, 06 | 4 labs pour 2 modules (6 h prévus) |
| Opérations NDB | NDB-06 à NDB-15 | Toutes couvertes sur le papier |
| Lab-05 | Déclare NDB-11, 12, 13 ; seul mkdir ndb_6 est fait pour l'ajout | **NDB-12 incomplète** : aucun nœud n'est ajouté, démarré, vérifié ; la conclusion affirme faussement NDB-12 réalisé |
| Lab-04 vs Lab-06 | Les deux testent « 2 STOP » + SHOW (failover) | **Redondance** : test de panne répété |
| Lab-06 | `pgrep -a mysqld` après arrêt affiche « mysqld arrete » (ce n'est pas une sortie pgrep réelle) ; en-têtes « Exemple de commande » dupliqués (lignes 861-862 et 941-942) | Résultat attendu inventé ; défaut de forme |
| Mermaid | Fig 2.1, 2.2, 2.3 : étiquettes guillemetées, conformes | Aucun défaut |

**Verdict** : couverture NDB complète mais durée déclarée incohérente avec le syllabus ; Lab-05 ne réalise pas NDB-12 ; redondance du test de panne entre Lab-04 et Lab-06.

### B.3 Chapitre 3 — Supervision et Maintenance (modules 3.0 + 3.1)

| Point | Constat | Écart / anomalie |
|---|---|---|
| Objectif déclaré | Supervision (ndb_mgm, ndb_config, ndb_desc), alertes, backup/restauration, remplacement nœud, MCM | Conforme syllabus 3.0 + 3.1 |
| Durée déclarée | 9 h (3 × 3 h) | **Non conforme** : syllabus 3.0 (3 h) + 3.1 (3 h) = 6 h, le chapitre déclare 9 h |
| Labs | Lab-07, 08, 09 | 3 labs pour 2 modules (6 h prévus) |
| Opérations NDB | NDB-16 à NDB-22 | Toutes couvertes sur le papier |
| Lab-07 | `ndb_desc` listé dans les outils mais aucune étape ne l'utilise | Outil documenté, pas mis en œuvre |
| Lab-08 | Étape 5 « Remplacement nœud » démarre NodeId 6 mais le SHOW final (étape 6) n'affiche que 2 nœuds de stockage (id=2, id=3) ; aucune panne n'est simulée avant le « remplacement » | **NDB-19 partielle** : vérification absente, scénario de remplacement incohérent |
| Lab-08 | Plusieurs blocs de résultat dupliqués (`# rc=0` répété, blocs de code vides) | Défauts de forme / copier-coller |
| Lab-09 (MCM) | `dpkg -l` et `which` indiquent « paquet mcm non installé » / « binaires mcm absents » ; les étapes suivantes lancent `mcmd` et `mcm` avec des sorties attendues inventées | **Lab non exécutable** : outil référencé, non installé, non testable (confirmé par tracking.state) |
| Mermaid | Fig 3.1, 3.2 : étiquettes guillemetées, conformes | Aucun défaut |

**Verdict** : durée déclarée incohérente ; Lab-08 remplacement incomplet ; Lab-09 (MCM) inutilisable en l'état (binaires absents).

### B.4 Chapitre 4 — Optimisation et Réplication (modules 4.0 + 4.1)

| Point | Constat | Écart / anomalie |
|---|---|---|
| Objectif déclaré | Paramètres perf, goulots, sharding/partitionnement, réplication inter-clusters, failover/failback | Conforme syllabus 4.0 + 4.1 |
| Durée déclarée | 12 h (4 × 3 h) | **Non conforme** : syllabus 4.0 (3 h) + 4.1 (3 h) = 6 h, le chapitre déclare le double |
| Labs | Lab-10, 11, 13, 14 (Lab-12 absent de ce chapitre, il est au chapitre 5) | Numérotation non séquentielle par chapitre (Lab-14 avant Lab-12) |
| Opérations NDB | NDB-23, 24, 25 (4.0) ; NDB-26, 27, 28 (4.1) | Toutes couvertes sur le papier |
| Lab-10 | Étape 5b : bloc de résultat attendu dupliqué/mélangé (SHOW répété puis ndb_config puis SHOW à nouveau) ; `sed -i` modifie config.ini puis redémarrage `--initial` des nodes de stockage (destructeur des données, piège noté) | Défaut de forme dans le résultat attendu |
| Lab-11 | Prépare ndb_7/ndb_8 (mkdir) mais n'ajoute ni ne démarre de nouveaux nœuds de stockage | **NDB-25 partielle** : pas de multi node group effectif, seulement de l'auto-sharding sur le node group existant |
| Lab-13 (réplication inter-clusters) | Le nœud SQL réplica (Id=6, port 3307) n'est jamais démarré ; `ndb_mgmd` de Cluster B lancé sans fichier de config ; tourne sur VM 3 qui héberge déjà le SQL NodeId 5 du cluster A ; non testable (confirmé tracking.state) | **Lab incomplet / non exécutable** : NDB-26 non réellement réalisable |
| Lab-14 | Dépend de la table `labrep.t_repl` créée en Lab-13 ; test de panne « 2 STOP » + SHOW déjà fait dans Lab-04 et Lab-06 | **Dépendance sur lab non testable** + **redondance** avec Lab-04/Lab-06 |
| Mermaid | Fig 4.1 et 4.3 conformes ; **Fig 4.2 (ligne 55-56) : étiquettes NON guillemetées `SQL1[mysqld]` / `SQL2[mysqld]`** | Défaut de convention Mermaid (labels sans guillemets) |

**Verdict** : durée déclarée incohérente ; Lab-13 incomplet (réplica non démarré) et non testable ; Lab-14 dépendant et redondant ; défaut Mermaid sur Fig 4.2.

### B.5 Chapitre 5 — Sécuriser MySQL Cluster (module 5.0)

| Point | Constat | Écart / anomalie |
|---|---|---|
| Objectif déclaré | TLS inter-nœuds, moindre privilège, sauvegardes protégées, isolement réseau | Conforme syllabus 5.0 |
| Durée déclarée | 6 h (1 × 6 h) | Conforme |
| Labs | Lab-12 | 1 lab pour 6 h, conforme |
| Opérations NDB | NDB-29, 30, 31 | Toutes couvertes |
| Contenu cyber | Uniquement dans ce chapitre ; avertissement et conclusion interdisent pentest/red team/SOC/SIEM/CVE/exploit/malware/IDS-IPS | Conforme (les chapitres 1-4 sont exempts de contenu cyber résiduel ; les seules occurrences sont dans les fichiers `.bak`/`.pre-fix` non modifiés) |
| Problèmes de forme | Blocs de résultat dupliqués (étapes 5b, 6b, 8b, 8d, 8f) ; bloc `# rc=0` isolé à l'étape 3d ; lignes `# rc=0` orphelines (945-946, 991-996, 1053-1056) | Défauts de copie/coller, pas de bloc « Corrigé » séparé (conforme à la règle) |
| Mermaid | Fig 5.1, 5.2 : étiquettes guillemetées, conformes | Aucun défaut |

**Verdict** : chapitre conforme, bien scoped, seul défaut : artefacts de copier-coller dans les résultats attendus.

---

## C. Incohérences inter-chapitres

### C.1 NodeId (contradiction majeure)

| Élément | Syllabus (source de vérité) | Chapitres 1-5 | Statut |
|---|---|---|---|
| VM 2 stockage NodeId | node-id 1 et 2 (ligne 11 du syllabus) | NodeId 2 et 3 | **Incohérent** |
| VM 1 gestion NodeId | non précisé | NodeId 1 | — |
| VM 1 SQL NodeId | non précisé | NodeId 4 | — |
| VM 3 SQL NodeId | non précisé | NodeId 5 | — |

Toutes les chapitres sont cohérentes entre elles (gestion=1, stockage=2 et 3, SQL=4 et 5), mais elles contredisent le syllabus qui indique des nœuds de stockage node-id 1 et 2. Il faut aligner soit le syllabus, soit les chapitres (et tous les schémas/config.ini/SHOW attendus).

### C.2 Adresses IP

| VM | Syllabus | Chapitres | Statut |
|---|---|---|---|
| VM 1 gestion + SQL | 192.168.56.10 | 192.168.56.10 | Cohérent |
| VM 2 stockage | 192.168.56.11 | 192.168.56.11 | Cohérent |
| VM 3 SQL | 192.168.56.12 | 192.168.56.12 | Cohérent |
| Hôte | 192.168.56.1 | 192.168.56.1 | Cohérent |

### C.3 Noms de nœuds / hostnames

| VM | Syllabus | Chapitres | Statut |
|---|---|---|---|
| VM 1 | non nommé | gestion-sql | OK (complément) |
| VM 2 | non nommé | stockage | OK |
| VM 3 | non nommé | mysql-node3 | OK |
| Noms VirtualBox | non précisés | UbuntuServer-01/02/03 | Cohérent avec tracking.state |

### C.4 Ordre de démarrage

Tous les chapitres : gestion → stockage → SQL. Cohérent avec le syllabus (1.1). Aucun écart.

### C.5 Durées déclarées vs syllabus

| Chapitre | Durée déclarée | Durée syllabus | Écart |
|---|---|---|---|
| 1 | 6 h | 6 h | Aucun |
| 2 | 12 h | 6 h | +6 h |
| 3 | 9 h | 6 h | +3 h |
| 4 | 12 h | 6 h | +6 h |
| 5 | 6 h | 6 h | Aucun |

### C.6 Numérotation des labs

Les labs ne sont pas séquentiels par chapitre : chapitre 4 contient Lab-10, 11, 13, 14 ; Lab-12 (sécurité) se trouve au chapitre 5. Un apprenant suit Lab-14 avant Lab-12. Mineur mais déroutant.

### C.7 Contradiction Internet / installation

Chapitres 1-4 : avertissement « pas d'accès Internet sur les nœuds pendant les labs », mais Lab-02 (chapitre 1) et les étapes d'installation MCM (Lab-09) requièrent `apt` / dépôt MySQL. Seul le chapitre 5 lève l'ambiguïté (« adaptateur NAT temporaire uniquement pendant l'installation des paquets »).

---

## D. Labs non complets ou inutiles

| Lab | Problème | Gravité | Recommandation |
|---|---|---|---|
| Lab-01 | Hors syllabus (préparation infra pure : netplan, SSH, hostname). Aucun TP NDB. Nécessaire comme prérequis mais non cartographié aux NDB-nn. | Mineur | Conserver comme pré-requis infrastructure, clarifier qu'il n'est pas un TP du syllabus, ou le rattacher à NDB-01. |
| Lab-02 | Conforme et validé en réel. | — | — |
| Lab-03 | Conforme. | — | — |
| Lab-04 | Test de panne redondant avec Lab-06 (même « 2 STOP » + SHOW). | Mineur | Fusionner ou différencier clairement (Lab-04 : quorum/node groups ; Lab-06 : mesure du temps de récupération + rolling). |
| Lab-05 | **NDB-12 incomplète** : seul `mkdir ndb_6` est effectué, aucun nœud ajouté/démarré/vérifié. | Majeur | Ajouter les étapes d'ajout effectif du NodeId 6 (config.ini + démarrage + SHOW) ou réduire le périmètre déclaré. |
| Lab-06 | Conforme et validé en réel (rolling restart SQL). Résultat attendu `pgrep` inventé. | Mineur | Remplacer par une sortie réelle. |
| Lab-07 | Conforme et validé en réel. `ndb_desc` documenté mais non utilisé. | Mineur | Supprimer `ndb_desc` des outils ou ajouter une étape. |
| Lab-08 | **NDB-19 partielle** : NodeId 6 démarré mais absent du SHOW de vérification ; aucune panne simulée avant le « remplacement ». | Majeur | Ajouter l'arrêt d'un nœud, le démarrage du remplaçant, et un SHOW incluant NodeId 6. |
| Lab-09 | **Non exécutable** : binaires `mcm`/`mcmd` absents (les propres vérifications du lab le disent). Sorties attendues inventées. | Bloquant | Soit installer MCM, soit convertir le lab en démonstration commentée / le retirer du parcours praticable. |
| Lab-10 | Conforme. Résultat attendu étape 5b dupliqué/mélangé. | Mineur | Corriger le bloc de résultat attendu. |
| Lab-11 | **NDB-25 partielle** : aucun nouveau nœud de stockage démarré, pas de multi node group effectif. | Mineur | Ajouter le démarrage des nodes ndb_7/ndb_8 ou recentrer sur l'auto-sharding existant. |
| Lab-13 | **Incomplet / non testable** : nœud SQL réplica (Id=6, port 3307) jamais démarré ; `ndb_mgmd` Cluster B sans fichier de config ; dépend de Lab-13 pour Lab-14. | Bloquant | Compléter le démarrage du SQL réplica et du gestionnaire avec config, ou marquer comme non réalisable sur l'infrastructure 3 VMs. |
| Lab-14 | Dépend de `labrep.t_repl` (Lab-13 non testable) ; redondant avec Lab-04/Lab-06 (failover). | Majeur | Rendre Lab-14 indépendant (créer sa propre table de test) ou le fusionner avec Lab-04. |

Labs inutiles/redondants avérés : aucun lab n'est totalement inutile, mais **Lab-09 (MCM)** n'apportent rien de testable en l'état, et le test de panne est triplé (Lab-04, Lab-06, Lab-14).

---

## E. Recommandations de correction (priorisées)

### Priorité 1 (bloquants — bloquent la remise à `student`)

1. **Lab-09 (MCM)** : installer les paquets/binaires `mcm`/`mcmd` sur les VM, ou convertir le lab en démonstration commentée sans exécution réelle, ou le retirer du périmètre praticable. L'état actuel (binaires absents, sorties inventées) ne permet pas un test débutant.
2. **Lab-13 (réplication inter-clusters)** : démarrer le nœud SQL réplica (Id=6, port 3307) sur VM 3 et fournir un fichier de config à `ndb_mgmd` de Cluster B ; sinon marquer le lab comme non réalisable sur 3 VMs et le retirer du parcours testable.
3. **Contradiction NodeId de stockage** : trancher entre le syllabus (stockage node-id 1 et 2 sur VM 2) et les chapitres (gestion=1, stockage=2 et 3, SQL=4 et 5), puis aligner config.ini, schémas et résultats attendus des SHOW dans tous les chapitres.

### Priorité 2 (majeurs — à corriger avant la remise)

4. **Lab-05 (NDB-12)** : réaliser l'ajout effectif d'un nœud de stockage (NodeId 6 : config.ini, démarrage, vérification SHOW) ou ne pas déclarer NDB-12 comme réalisé.
5. **Lab-08 (NDB-19)** : simuler une panne de nœud avant le remplacement, démarrer le nœud de remplacement et afficher un SHOW final incluant le nouveau NodeId.
6. **Lab-14** : rendre indépendant de Lab-13 (créer sa propre table de test) et/ou lever la redondance avec Lab-04/Lab-06 sur le test de panne.
7. **Durées déclarées** : aligner les durées des chapitres 2 (6 h), 3 (6 h), 4 (6 h) sur le syllabus, ou réduire le nombre de labs (4 labs déclarés pour 6 h prévus au chapitre 2 et 4).

### Priorité 3 (mineurs — qualité de forme)

8. **Preuves** : ajouter les en-têtes `# date:`, `# cmd:`, `# rc=` et utiliser `tee`/`script` pour capturer les sorties réelles (règle 7 du format canonique). Remplacer les blocs `# rc=0` et les sorties inventées par des exécutions réelles.
9. **Mermaid** : mettre les étiquettes entre guillemets dans le chapitre 4 (Fig 4.2 : `SQL1["mysqld"]`, `SQL2["mysqld"]`) pour homogénéité avec les autres schémas.
10. **Artefacts de copier-coller** : supprimer les blocs dupliqués (`# rc=0` orphelins, blocs vides, tableaux répétés) aux chapitres 4 et 5 (étapes 3d, 5b, 6b, 8b, 8d, 8f de chapitre 5 ; étape 5b de chapitre 4).
11. **Contradiction Internet** : ajouter à tous les chapitres (ou dans l'avertissement commun) la précision « adaptateur NAT temporaire uniquement pendant l'installation des paquets » déjà présente au chapitre 5.
12. **Numérotation des labs** : rénumérer pour que Lab-12 (sécurité) ne succède pas à Lab-14, ou clarifier l'ordre de progression.

### Suivi post-correction

Tout changement de commande ou de résultat attendu impose un nouvel auto-test complet en environnement propre (selon le cycle de production). Une simple correction de formulation autorise un re-test ciblé. Le bilan doit être revisité après chaque correction versionnée dans `CHANGELOG.md`.

---

## F. Synthèse

- **Ce qui va** : architecture des 5 chapitres conforme au syllabus (9 modules sur 9) ; 31/31 opérations NDB déclarées ; chapitres 1-4 exempts de contenu cyber résiduel (conforme à la consigne « cyber uniquement au chapitre 5 ») ; chapitre 5 bien scoped et conforme (6 h, 1 lab, NDB-29/30/31) ; IPs, hostnames, ordre de démarrage cohérents ; VMs et snapshots conformes.
- **Ce qui ne va pas** : durées déclarées surestimées aux chapitres 2, 3, 4 ; contradiction NodeId stockage entre syllabus et chapitres ; Lab-09 (MCM) non exécutable ; Lab-13 incomplet (réplica SQL absent) ; Lab-05 (NDB-12) et Lab-08 (NDB-19) incomplets ; redondance du test de panne (3 fois) ; preuves non conformes (pas d'en-têtes `# date:`/`# cmd:`/`# rc=`) ; quelques étiquettes Mermaid non guillemetées (chapitre 4 Fig 4.2) ; artefacts de copier-coller dans les résultats attendus (chapitres 4 et 5).

Le fichier `bilan.md` est maintenant créé. Je le commite et le pousse sur `main`.
<tool_call>
<function=bash>