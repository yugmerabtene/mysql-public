# Bilan d'analyse — Chapitres 1 à 5 (MySQL Cluster)

**Auteur** : agent `prof` — parcours « MySQL Cluster : Administration et exploitation »
**Cible** : `chapitre-01.md` à `chapitre-05.md` par rapport à `syllabus.md` (source de vérité)
**Date** : 2026-11-22
**Contraintes respectées** : aucun chapitre modifié hors corrections demandées, aucun fichier `.bak`/`.pre-fix` touché, seul `bilan.md` est produit.

---

## A. Vue d'ensemble

### A.1 Couverture structurelle

| Élément | Valeur constatée | Référence syllabus | Écart |
|---|---|---|---|
| Nombre de chapitres | 5 (chapitre-01 à chapitre-05) | 5 jours (Jour 1 à Jour 5) | Aucun |
| Modules couverts | 1.0, 1.1, 2.0, 2.1, 3.0, 3.1, 4.0, 4.1, 5.0 | 9 modules | Aucun module manquant |
| Nombre de labs définis | 14 (Lab-01 à Lab-14) | 9 travaux pratiques de module (un par module) | 5 labs supplémentaires (découpage et prépa infra) |
| Durée déclarée | J1=6h, J2=12h, J3=9h, J4=12h, J5=6h (total 45h) | J1=6h, J2=6h, J3=6h, J4=6h, J5=6h (total 30h) | +15h déclarées sur J2, J3, J4 |
| Opérations NDB déclarées | NDB-01 à NDB-31 (31/31) | NDB-01 à NDB-31 (31) | 100 % sur le papier (voir A.2) |
| VMs utilisées | 3 (192.168.56.10, .11, .12) | Maximum 3, idéalement 2 | Conforme au maximum, pas à l'idéal |
| Réseau | vboxnet0 192.168.56.0/24, DHCP off | Idem | Conforme |

### A.2 Taux de couverture des opérations NDB (NDB-01 à NDB-31)

| Opération | ID | Chapitre | Lab | Statut (testé en réel / non testable) | Commentaire |
|---|---|---|---|---|---|
| Présentation des composants | NDB-01 | 1.0 | Lab-01 / Lab-02 | Testé en réel | Cours + `SHOW` |
| Études de cas | NDB-02 | 1.0 | Lab-01 / Lab-02 | Partielle | Texte uniquement, pas de lab dédié « exploration composants / études de cas » |
| Installation composants | NDB-03 | 1.1 | Lab-02 | Testé en réel | Validé sur les 3 VM |
| Configuration initiale | NDB-04 | 1.1 | Lab-02 | Testé en réel | `config.ini` (NoOfReplicas=2) |
| Vérification intégrité | NDB-05 | 1.1 | Lab-02 | Testé en réel | `SHOW` (5 nœuds connectés) |
| Dimensionnement résilience | NDB-08 | 1.1 | Lab-02 | Testé en réel | `NoOfReplicas = 2` |
| Moteur NDB | NDB-06 | 2.0 | Lab-03 | Testé en réel | — |
| Types de nœuds | NDB-07 | 2.0 | Lab-03 | Testé en réel | — |
| Quorum et split-brain | NDB-09 | 2.0 | Lab-04 | Non testé en réel | Lab-04 non encore exécuté en réel |
| Node groups | NDB-10 | 2.0 | Lab-04 | Non testé en réel | Lab-04 non encore exécuté en réel |
| Configuration nœuds | NDB-11 | 2.1 | Lab-05 | Non testé en réel | Lab-05 non encore exécuté en réel |
| Ajout/suppression nœuds | NDB-12 | 2.1 | Lab-05 | **Incomplet** | Seul `mkdir ndb_6` effectué, aucun nœud ajouté/démarré/vérifié |
| Surveillance état | NDB-13 | 2.1 | Lab-05 | Non testé en réel | Lab-05 non encore exécuté en réel |
| Test de panne | NDB-14 | 2.1 | Lab-04 / Lab-06 | Non testé en réel | Labs non encore exécutés en réel |
| Redémarrage rolling | NDB-15 | 2.1 | Lab-06 | Non testé en réel | Lab-06 non encore exécuté en réel |
| Outils de supervision | NDB-16 | 3.0 | Lab-07 | Testé en réel | Validé en réel |
| Tâches maintenance | NDB-17 | 3.0 | Lab-07 | Testé en réel | Validé en réel |
| Sauvegarde/restauration | NDB-18 | 3.0 | Lab-08 | Testé en réel | Validé en réel |
| Remplacement nœud défaillant | NDB-19 | 3.0 | Lab-08 | **Partiel** | NodeId 6 démarré mais absent du SHOW final de vérification |
| Installation agents MCM | NDB-20 | 3.1 | Lab-09 | **Non testable** | MCM commercial Oracle, binaires `mcm`/`mcmd` absents, pas d'Internet |
| Création clusters MCM | NDB-21 | 3.1 | Lab-09 | **Non testable** | Idem NDB-20 |
| Gestion clusters MCM | NDB-22 | 3.1 | Lab-09 | **Non testable** | Idem NDB-20 |
| Paramètres performance | NDB-23 | 4.0 | Lab-10 | Testé en réel | Validé en réel |
| Goulots d'étranglement | NDB-24 | 4.0 | Lab-10 | Testé en réel | Validé en réel |
| Sharding/partitionnement | NDB-25 | 4.0 | Lab-11 | Testé en réel | Préparation ndb_7/ndb_8, pas de démarrage de nouveaux nodes (partiel) |
| Réplication inter-clusters | NDB-26 | 4.1 | Lab-13 | **Non testable** | Second cluster requis, SQL réplica Id=6 jamais démarré |
| Gestion pannes | NDB-27 | 4.1 | Lab-14 | Testé en réel | Validé en réel |
| Failover/failback | NDB-28 | 4.1 | Lab-14 | Testé en réel | Validé en réel |
| Sécurité connexions (TLS) | NDB-29 | 5.0 | Lab-12 | Testé en réel | Validé en réel |
| Sécurité données (moindre privilège) | NDB-30 | 5.0 | Lab-12 | Testé en réel | Validé en réel |
| Sécurité nœuds serveurs | NDB-31 | 5.0 | Lab-12 | Testé en réel | Validé en réel |

**Taux déclarée** : 31/31 = 100 %.
**Taux effectif réalisable en l'état** : inférieur, car NDB-20/21/22 (MCM absent), NDB-12 (ajout non réalisé), NDB-19 (vérification absente) et NDB-26 (lab incomplet) ne sont pas effectivement exécutables.

Labs validés en réel : Lab-01, Lab-02, Lab-07, Lab-08, Lab-10, Lab-11, Lab-12, Lab-14 (8/14).
Labs non encore testés en réel : Lab-03, Lab-04, Lab-05, Lab-06, Lab-13 (5/14).
Labs non testables : Lab-09 (MCM commercial, binaires absents, pas d'Internet), Lab-13 (second cluster requis).

---

## B. Tableau des opérations NDB (NDB-01 à NDB-31)

Voir la section A.2 ci-dessus (tableau complet avec statut et commentaire par opération).

---

## C. Analyse chapitre par chapitre

### C.1 Chapitre 1 — Introduction et installation (modules 1.0 + 1.1)

| Point | Constat | Écart / anomalie |
|---|---|---|
| Objectif déclaré | Architecture NDB, 3 VM, `config.ini`, démarrage ordonné, vérification intégrité, résilience | Conforme syllabus 1.0 + 1.1 |
| Durée déclarée | 6 h (2 × 3 h) | Conforme (3 h + 3 h) |
| Labs | Lab-01 (prépa infra 3 VM), Lab-02 (installation cluster) | Lab-01 n'existe pas dans le syllabus (pré-requis infrastructure implicite) ; hors périmètre NDB mais nécessaire |
| Opérations NDB | NDB-01, 02, 03, 04, 05, 08 | Toutes les opérations du Jour 1 couvertes sur le papier |
| Incohérences | Syllabus ligne 11 : « deux nœuds de stockage (ndbmtd node-id 1 et 2) » sur VM 2 ; les chapitres utilisent NodeId 1 = gestion, NodeId 2 et 3 = stockage | **Contradiction syllabus ↔ chapitres sur les NodeId de stockage** |
| Problème commande | `apt-get update` / `apt-get install` (Lab-02) alors que l'avertissement interdit l'accès Internet sur les nœuds pendant les labs | Contradiction avertissement vs étapes d'installation (résolu seulement au chapitre 5 par un adaptateur NAT temporaire) |

**Verdict** : chapitre cohérent, mais Lab-01 est une prépa infra hors syllabus et la contradiction NodeId (syllabus 1 et 2 vs chapitres 2 et 3 pour le stockage) doit être tranchée.

### C.2 Chapitre 2 — Architecture et Administration (modules 2.0 + 2.1)

| Point | Constat | Écart / anomalie |
|---|---|---|
| Objectif déclaré | Architecture NDB détaillée, config nœuds, ajout/suppression, surveillance, panne, rolling restart | Conforme syllabus 2.0 + 2.1 |
| Durée déclarée | 12 h (4 × 3 h) | **Non conforme** : syllabus 2.0 (3 h) + 2.1 (3 h) = 6 h, le chapitre déclare le double |
| Labs | Lab-03, 04, 05, 06 | 4 labs pour 2 modules (6 h prévus) |
| Opérations NDB | NDB-06 à NDB-15 | Toutes couvertes sur le papier |
| Lab-05 | Déclare NDB-11, 12, 13 ; seul `mkdir ndb_6` est fait pour l'ajout | **NDB-12 incomplète** : aucun nœud n'est ajouté, démarré, vérifié ; la conclusion affirme faussement NDB-12 réalisé |
| Lab-04 vs Lab-06 | Les deux testent « 2 STOP » + SHOW (failover) | **Redondance** : test de panne répété |
| Lab-06 | `pgrep -a mysqld` après arrêt affiche « mysqld arrete » (ce n'est pas une sortie pgrep réelle) ; en-têtes dupliqués | Résultat attendu inventé ; défaut de forme |

**Verdict** : couverture NDB complète mais durée déclarée incohérente avec le syllabus ; Lab-05 ne réalise pas NDB-12 ; redondance du test de panne entre Lab-04 et Lab-06.

### C.3 Chapitre 3 — Supervision et Maintenance (modules 3.0 + 3.1)

| Point | Constat | Écart / anomalie |
|---|---|---|
| Objectif déclaré | Supervision (`ndb_mgm`, `ndb_config`, `ndb_desc`), alertes, backup/restauration, remplacement nœud, MCM | Conforme syllabus 3.0 + 3.1 |
| Durée déclarée | 9 h (3 × 3 h) | **Non conforme** : syllabus 3.0 (3 h) + 3.1 (3 h) = 6 h, le chapitre déclare 9 h |
| Labs | Lab-07, 08, 09 | 3 labs pour 2 modules (6 h prévus) |
| Opérations NDB | NDB-16 à NDB-22 | Toutes couvertes sur le papier |
| Lab-07 | `ndb_desc` listé dans les outils mais aucune étape ne l'utilise | Outil documenté, pas mis en œuvre |
| Lab-08 | Étape « Remplacement nœud » démarre NodeId 6 mais le SHOW final n'affiche que 2 nœuds de stockage (id=2, id=3) ; aucune panne simulée avant le « remplacement » | **NDB-19 partielle** : vérification absente, scénario de remplacement incohérent |
| Lab-09 (MCM) | Binaires `mcm`/`mcmd` absents, pas d'accès Internet, pas de licence Oracle | **Lab non réalisable** : documenté comme démonstration théorique uniquement, opérations NDB-20/21/22 non exécutables |

**Verdict** : durée déclarée incohérente ; Lab-08 remplacement incomplet ; Lab-09 (MCM) documenté comme non réalisable sur l'infrastructure actuelle.

### C.4 Chapitre 4 — Optimisation et Réplication (modules 4.0 + 4.1)

| Point | Constat | Écart / anomalie |
|---|---|---|
| Objectif déclaré | Paramètres perf, goulots, sharding/partitionnement, réplication inter-clusters, failover/failback | Conforme syllabus 4.0 + 4.1 |
| Durée déclarée | 12 h (4 × 3 h) | **Non conforme** : syllabus 4.0 (3 h) + 4.1 (3 h) = 6 h, le chapitre déclare le double |
| Labs | Lab-10, 11, 13, 14 (Lab-12 sécurité est au chapitre 5) | Numérotation non séquentielle par chapitre |
| Opérations NDB | NDB-23, 24, 25 (4.0) ; NDB-26, 27, 28 (4.1) | Toutes couvertes sur le papier |
| Lab-11 | Prépare ndb_7/ndb_8 (mkdir) mais n'ajoute ni ne démarre de nouveaux nœuds de stockage | **NDB-25 partielle** : pas de multi node group effectif |
| Lab-13 (réplication inter-clusters) | Nœud SQL réplica (Id=6, port 3307) jamais démarré ; `ndb_mgmd` de Cluster B lancé sans fichier de config ; tourne sur VM 3 qui héberge déjà le SQL NodeId 5 du cluster A | **Lab incomplet / non testable** : NDB-26 non réellement réalisable sur 3 VMs |
| Lab-14 | Dépend de la table `labrep.t_repl` créée en Lab-13 ; test de panne déjà fait dans Lab-04 et Lab-06 | **Dépendance sur lab non testable** + **redondance** avec Lab-04/Lab-06 |
| Mermaid | Fig 4.2 : étiquettes NON guillemetées `SQL1[mysqld]` / `SQL2[mysqld]` | Défaut de convention Mermaid (labels sans guillemets) |

**Verdict** : durée déclarée incohérente ; Lab-13 incomplet (réplica non démarré) et non testable ; Lab-14 dépendant et redondant ; défaut Mermaid sur Fig 4.2.

### C.5 Chapitre 5 — Sécuriser MySQL Cluster (module 5.0)

| Point | Constat | Écart / anomalie |
|---|---|---|
| Objectif déclaré | TLS inter-nœuds, moindre privilège, sauvegardes protégées, isolement réseau | Conforme syllabus 5.0 |
| Durée déclarée | 6 h (1 × 6 h) | Conforme |
| Labs | Lab-12 | 1 lab pour 6 h, conforme |
| Opérations NDB | NDB-29, 30, 31 | Toutes couvertes |
| Contenu cyber | Uniquement dans ce chapitre ; avertissement et conclusion interdisent pentest/red team/SOC/SIEM/CVE/exploit/malware/IDS-IPS | Conforme (les chapitres 1-4 sont exempts de contenu cyber résiduel) |
| Problèmes de forme | Blocs de résultat dupliqués (étapes 5b, 6b, 8b, 8d, 8f) ; bloc `# rc=0` isolé ; lignes `# rc=0` orphelines | Défauts de copie/coller, pas de bloc « Corrigé » séparé (conforme à la règle) |

**Verdict** : chapitre conforme, bien scoped, seul défaut : artefacts de copier-coller dans les résultats attendus.

---

## D. Incohérences inter-chapitres

### D.1 NodeId, IPs, noms de nœuds, ordre de démarrage, durées

| Élément | Syllabus (source de vérité) | Chapitres 1-5 | Statut |
|---|---|---|---|
| VM 2 stockage NodeId | node-id 1 et 2 (syllabus) | NodeId 2 et 3 | **Incohérent** |
| VM 1 gestion NodeId | non précisé | NodeId 1 | — |
| VM 1 SQL NodeId | non précisé | NodeId 4 | — |
| VM 3 SQL NodeId | non précisé | NodeId 5 | — |
| VM 1 IP | 192.168.56.10 | 192.168.56.10 | Cohérent |
| VM 2 IP | 192.168.56.11 | 192.168.56.11 | Cohérent |
| VM 3 IP | 192.168.56.12 | 192.168.56.12 | Cohérent |
| Hôte IP | 192.168.56.1 | 192.168.56.1 | Cohérent |
| Ordre de démarrage | gestion → stockage → SQL | gestion → stockage → SQL | Cohérent |

Toutes les chapitres sont cohérentes entre elles (gestion=1, stockage=2 et 3, SQL=4 et 5), mais elles contredisent le syllabus qui indique des nœuds de stockage node-id 1 et 2. Il faut aligner soit le syllabus, soit les chapitres (et tous les schémas/config.ini/SHOW attendus).

### D.2 Labs non complets ou inutiles

| Lab | Problème | Gravité | Recommandation |
|---|---|---|---|
| Lab-01 | Hors syllabus (préparation infra pure : netplan, SSH, hostname). Aucun TP NDB. Nécessaire comme prérequis mais non cartographié aux NDB-nn. | Mineur | Conserver comme pré-requis infrastructure, clarifier qu'il n'est pas un TP du syllabus. |
| Lab-04 | Test de panne redondant avec Lab-06 (même « 2 STOP » + SHOW). | Mineur | Fusionner ou différencier clairement. |
| Lab-05 | **NDB-12 incomplète** : seul `mkdir ndb_6` effectué, aucun nœud ajouté/démarré/vérifié. | Majeur | Ajouter les étapes d'ajout effectif du NodeId 6 (config.ini + démarrage + SHOW) ou réduire le périmètre déclaré. |
| Lab-06 | Résultat attendu `pgrep` inventé. | Mineur | Remplacer par une sortie réelle. |
| Lab-08 | **NDB-19 partielle** : NodeId 6 démarré mais absent du SHOW de vérification ; aucune panne simulée avant le « remplacement ». | Majeur | Ajouter l'arrêt d'un nœud, le démarrage du remplaçant, et un SHOW incluant NodeId 6. |
| Lab-09 | **Non exécutable** : binaires `mcm`/`mcmd` absents (produit commercial Oracle, pas de licence, pas d'Internet). Sorties attendues inventées dans l'ancienne version. | Bloquant | Documenté comme non réalisable (démonstration théorique uniquement) — conserver en l'état ou retirer du périmètre praticable. |
| Lab-11 | **NDB-25 partielle** : aucun nouveau nœud de stockage démarré, pas de multi node group effectif. | Mineur | Ajouter le démarrage des nodes ndb_7/ndb_8 ou recentrer sur l'auto-sharding existant. |
| Lab-13 | **Incomplet / non testable** : nœud SQL réplica (Id=6, port 3307) jamais démarré ; `ndb_mgmd` Cluster B sans fichier de config ; dépend de Lab-13 pour Lab-14. | Bloquant | Compléter le démarrage du SQL réplica et du gestionnaire avec config, ou marquer comme non réalisable sur l'infrastructure 3 VMs. |
| Lab-14 | Dépend de `labrep.t_repl` (Lab-13 non testable) ; redondant avec Lab-04/Lab-06 (failover). | Majeur | Rendre Lab-14 indépendant (créer sa propre table de test) ou le fusionner avec Lab-04. |

Labs inutiles/redondants avérés : aucun lab n'est totalement inutile, mais **Lab-09 (MCM)** n'apporte rien de testable en l'état, et le test de panne est triplé (Lab-04, Lab-06, Lab-14).

---

## E. Recommandations de correction (priorisées)

### Priorité 1 (bloquants — bloquent la remise à `student`)

1. **Lab-09 (MCM)** : documenté comme non réalisable (démonstration théorique uniquement, binaires `mcm`/`mcmd` absents, produit commercial Oracle, pas d'accès Internet). Conserver en l'état ou retirer du périmètre praticable avant remise à `student`.
2. **Lab-13 (réplication inter-clusters)** : démarrer le nœud SQL réplica (Id=6, port 3307) sur VM 3 et fournir un fichier de config à `ndb_mgmd` de Cluster B ; sinon marquer le lab comme non réalisable sur 3 VMs et le retirer du parcours testable.
3. **Contradiction NodeId de stockage** : trancher entre le syllabus (stockage node-id 1 et 2 sur VM 2) et les chapitres (gestion=1, stockage=2 et 3, SQL=4 et 5), puis aligner `config.ini`, schémas et résultats attendus des `SHOW` dans tous les chapitres.

### Priorité 2 (majeurs — à corriger avant la remise)

4. **Lab-05 (NDB-12)** : réaliser l'ajout effectif d'un nœud de stockage (NodeId 6 : `config.ini`, démarrage, vérification `SHOW`) ou ne pas déclarer NDB-12 comme réalisé.
5. **Lab-08 (NDB-19)** : simuler une panne de nœud avant le remplacement, démarrer le nœud de remplacement et afficher un `SHOW` final incluant le nouveau NodeId.
6. **Lab-14** : rendre indépendant de Lab-13 (créer sa propre table de test) et/ou lever la redondance avec Lab-04/Lab-06 sur le test de panne.
7. **Durées déclarées** : aligner les durées des chapitres 2 (6 h), 3 (6 h), 4 (6 h) sur le syllabus, ou réduire le nombre de labs.

### Priorité 3 (mineurs — qualité de forme)

8. **Preuves** : ajouter les en-têtes `# date:`, `# cmd:`, `# rc=` et utiliser `tee`/`script` pour capturer les sorties réelles (règle 7 du format canonique). Remplacer les blocs `# rc=0` et les sorties inventées par des exécutions réelles.
9. **Mermaid** : mettre les étiquettes entre guillemets dans le chapitre 4 (Fig 4.2 : `SQL1["mysqld"]`, `SQL2["mysqld"]`) pour homogénéité avec les autres schémas.
10. **Artefacts de copier-coller** : supprimer les blocs dupliqués (`# rc=0` orphelins, blocs vides, tableaux répétés) aux chapitres 4 et 5.
11. **Contradiction Internet** : ajouter à tous les chapitres la précision « adaptateur NAT temporaire uniquement pendant l'installation des paquets » déjà présente au chapitre 5.
12. **Numérotation des labs** : rénumérer pour que Lab-12 (sécurité) ne succède pas à Lab-14, ou clarifier l'ordre de progression.

---

## Conclusion et recommandation finale

Les chapitres 1 à 5 couvrent l'intégralité du syllabus (9 modules sur 9, 31/31 opérations NDB déclarées) et respectent les contraintes de sécurité (contenu cyber uniquement au chapitre 5 ; chapitres 1-4 exempts de contenu cyber résiduel ; IPs, hostnames et ordre de démarrage cohérents).

Cependant, plusieurs points bloquent la remise à `student` : **Lab-09 (MCM)** est documenté comme non réalisable sur l'infrastructure actuelle (binaires absents, produit commercial Oracle, pas d'Internet) ; **Lab-13** est incomplet/non testable (second cluster requis) ; **Lab-05 (NDB-12)** et **Lab-08 (NDB-19)** sont incomplets ; les durées déclarées des chapitres 2, 3 et 4 sont surestimées par rapport au syllabus ; une contradiction NodeId de stockage persiste entre le syllabus et les chapitres.

**Recommandation finale** : appliquer les corrections de priorité 1 (notamment confirmer le statut non réalisable de Lab-09 et de Lab-13, et trancher la contradiction NodeId) puis les corrections de priorité 2 avant toute remise à `student`. Tout changement de commande ou de résultat attendu impose un nouvel auto-test complet en environnement propre selon le cycle de production.
