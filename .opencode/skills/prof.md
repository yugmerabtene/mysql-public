---
name: Playbook MySQL Cluster
description: Procédures de formation pour les 5 jours, outils, labs isolés, configuration réelle en lab, détection, mitigation et reporting.
---

# Playbook MySQL Cluster

## 1. Usage

Ce skill sert à `prof` pour concevoir les briefings, démonstrations, labs, corrigés intégrés et analyses de
détection. Il est également lisible par `orchestrator` pour contrôler la qualité.

Tout contenu doit rester **local, isolé, autorisé et pédagogique**. Les commandes sont des exemples à
adapter au lab ; elles ne doivent jamais être pointées vers un système hors lab.

## 1.1 Production du contenu

### Cours

Structure recommandée :

```markdown
# <Jour>.<Module> — <Titre>

## 1. Objectifs
## 2. Prérequis
## 3. Vocabulaire
## 4. Risques et contrôles
## 5. Notions essentielles
## 6. Démonstration contrôlée
## 7. Limites et risques
## 8. Ce qu'il faut retenir
## 9. Question de vérification
```

Règles :

- définir chaque terme technique à sa première apparition ;
- ne pas supposer de connaissance non enseignée ;
- distinguer clairement le lab du reste ;
- expliquer la détection et la mitigation dès le cours ;
- rester concis : 10 à 15 minutes de lecture.

### Lab

Structure obligatoire (format canonique, voir `AGENTS.md`) :

````markdown
## Lab-XX — Titre du lab

### Énoncé / Contexte

Objectif, périmètre, phase de référence, place dans la chaîne, prérequis et
conditions de sécurité.

### Outils et commandes utilisées

| Outil | Commande | Rôle |
|---|---|---|

### Commande et laboratoire étape par étape

#### Étape N — Action

**But** — objectif concret de l'étape, en une phrase.

**Machine** — machine source et cible, avec adresses IP.

**Prérequis** — état, service, port, snapshot ou outil nécessaire avant l'action.

> **Machine** : ... | **Terminal** : ... | **Utilisateur** : ... | **Répertoire** : ...

**Exemple de commande**

```bash
commande --option argument
```

**Explication de la commande**

- `commande` : ce qu'elle fait et pourquoi elle est utilisée ici.
- `--option` : effet exact de l'option dans ce contexte.
- `argument` : rôle de l'adresse, du port, du chemin ou du fichier.
- `redirection` : destination de la sortie et preuve produite.
- `piège` : erreur courante à éviter.

**Résultat attendu**

```text
sortie réelle, extraite d'une exécution de laboratoire
```

**Preuve** : `preuves/.../fichier.txt`, avec `# date:`, `# cmd:` et `# rc=`.

### En conclusion

Synthèse, critères de réussite et renvoi vers le lab suivant.
````

Règles bloquantes :

- titre `## Lab-XX — ...`, jamais `## 6. Lab-01 — ...` ;
- exactement quatre sections `###` : `Énoncé / Contexte`, `Outils et commandes utilisées`, `Commande et laboratoire étape par étape`, `En conclusion` ;
- aucune section autonome `Plan de référence`, `Prérequis`, `Preuves à collecter` ou `Critères de réussite` ;
- chaque étape commence par `**But**`, `**Machine**`, `**Prérequis**`, puis l'encart de localisation ;
- ordre d'une étape : commande → explication en liste → résultat attendu ;
- une ligne de liste par commande, option, argument, redirection ou piège ;
- scripts de plus de 15 lignes commentés bloc par bloc ;
- aucune commande, preuve ou référence existante supprimée lors d'une refonte de forme ;
- aucun `Changelog`, note de version ou liste de modifications dans le chapitre : historique dans `CHANGELOG.md`.

### Exercices

Progression :

1. **Guidé** : reproduction pas à pas.
2. **Semi-guidé** : objectif et indices, sans toutes les commandes.
3. **Autonome** : objectif et critères de réussite seulement.
4. **Variante** : changement de machine, de port, de service ou de protection.

Chaque exercice précise : objectif, entrée, sortie attendue, critère de réussite, durée du lab.

### Solution intégrée

La solution est intégrée au déroulé du lab : chaque commande est suivie de son explication
en liste, puis de son résultat attendu. Il n'y a pas de fichier de corrigé séparé et
aucune solution séparée n'est transmise à `student` avant la fin de son test.

La solution intégrée contient : la solution de référence, les variantes acceptables, les
erreurs fréquentes et leur cause, les points de vérification et les limites.

## 1.2 Auto-test obligatoire

L'auto-test se fait dans un **environnement propre**, comme si tu découvrais le lab.

### Checklist

- [ ] Snapshot propre.
- [ ] Prérequis installés et documentés.
- [ ] Chaque commande exécutée telle qu'écrite.
- [ ] Chaque résultat attendu réellement obtenu.
- [ ] Chaque preuve réellement collectable.
- [ ] Durée mesurée.
- [ ] Erreurs fréquentes reproduites et documentées.
- [ ] Solution intégrée cohérente avec le lab.
- [ ] Détection et mitigation vérifiables.
- [ ] Aucune connaissance implicite.
- [ ] Aucun contenu réutilisable hors lab.

### Rapport d'auto-test

```markdown
# Auto-test — <module> — v<N>

## Environnement
## Prérequis
## Déroulé
| Étape | Commande | Attendu | Obtenu | Statut |
|---|---|---|---|---|
## Durée réelle
## Problèmes
## Corrections
## Points à surveiller
## Conclusion : passed | failed
```

Si le self-test est `failed`, le contenu n'est pas remis à `student`.

## 1.3 Correction après feedback

### Triage

| Sévérité | Traitement |
|---|---|
| `blocker` | Correction obligatoire avant re-test. |
| `major` | Correction obligatoire avant validation. |
| `minor` | Correction ou justification. |
| `suggestion` | Acceptée, planifiée ou refusée avec justification. |

### Journal de corrections

```markdown
# Corrections — <module> — v<N>

## Source
## Points
| ID | Sévérité | Remarque | Décision | Fichier | Statut |
|---|---|---|---|---|---|
## Changements de déroulé
## Nouveau self-test
## Points à re-tester
## Réponse à student
```

### Réponse à student

```text
ID :
Décision : corrigé | contourné | refusé
Justification :
Fichier modifié :
Version :
Re-test demandé :
```

## 1.4 Versionnage

- `v1` : première version auto-testée.
- `v2`, `v3` : corrections après feedback.
- Chaque version indique la date et le résumé des changements.
- Une correction de commande ou de résultat impose un self-test complet.
- Une correction de formulation peut se limiter à un re-test ciblé.

## 2. Chaîne d'engagement pédagogique

```text
Cadrage → Installation → Configuration → Administration → Supervision → Optimisation → Sécurisation → Restitution
```

À chaque étape :

- quel est l'objectif ;
- quelle est la machine autorisée ;
- quelle est la preuve attendue ;
- quel journal ou quelle alerte permet de détecter ;
- quelle mesure empêche ou limite.

## 3. Matrice outils

| Outil | Compétence | Exemple de lab | Détection | Mitigation |
|---|---|---|---|---|
| `ndb_mgm` | Gestion du cluster | Vérification état des nœuds | Alerte si nœud déconnecté | Vérification préalable du démarrage |
| `ndb_config` | Configuration | Lecture configuration | Erreur de configuration | Validation des paramètres |
| `mysqld` | Serveur SQL | Connexion au cluster | Erreur de connexion | Moindre privilège, authentification |
| `ndb_mgmd` | Nœud de gestion | Démarrage du gestionnaire | Échec de démarrage | Redondance des gestionnaires |
| `ndbmtd` | Nœud de stockage | Stockage des données | Échec de stockage | Répartition des données |
| MySQL Cluster Manager | Gestion centralisée | Création de clusters | Erreur de gestion | Sauvegarde des configurations |
| `mysqldump` | Sauvegarde | Export des données | Échec de sauvegarde | Vérification des sauvegardes |
| `ndb_restore` | Restauration | Import des données | Échec de restauration | Test de restauration régulière |
| Wireshark | Analyse réseau | Capture PCAP | Trafic anormal | Chiffrement, segmentation |
| `tcpdump` | Capture CLI | Capture du lab | Capture, corrélation | Journalisation centralisée |

## 4. Jour 1 — Introduction et installation

### 4.1 Présentation de MySQL Cluster

Objectifs :

- comprendre l'architecture de MySQL Cluster ;
- identifier les composants principaux ;
- comprendre pourquoi MySQL Cluster est adapté aux applications critiques.

Exemples de commandes :

```bash
# Vérification de l'installation
ndb_mgm -e "SHOW"
# Version du serveur
mysqld --version
```

Preuves : sortie horodatée, tableau composant/version/état.

Détection : absence de réponse, nœud non connecté.

Mitigation : vérification préalable, documentation de l'architecture.

### 4.2 Installation

Objectifs :

- installer les composants du cluster ;
- configurer le démarrage initial ;
- vérifier l'intégrité de l'installation.

Exemple de démarche :

```bash
# Installation des composants
apt-get install mysql-cluster-community-server mysql-cluster-community-client
# Démarrage du nœud de gestion
ndb_mgmd --config-file=/var/lib/mysql-cluster/config.ini
# Vérification
ndb_mgm -e "SHOW"
```

Ne jamais configurer un cluster hors lab sans validation.

Détection : échec de démarrage, nœud non visible.

Mitigation : documentation, tests préalables, sauvegarde des configurations.

## 5. Jour 2 — Architecture et administration

### 5.1 Architecture

Rappels :

- moteur de stockage NDB ;
- types de nœuds : gestion, stockage, SQL ;
- partitionnement et réplication ;
- redondance et résilience.

### 5.2 Configuration et administration

Objectifs :

- configurer les nœuds de gestion, de stockage et SQL ;
- ajouter et supprimer des nœuds ;
- surveiller l'état du cluster.

Commandes utiles :

```bash
# État du cluster
ndb_mgm -e "SHOW"
# Configuration
ndb_config --query-all
# Ajout d'un nœud
ndb_mgm -e "ADD NODE <id>"
```

Détection : nœud absent, erreur de configuration.

Mitigation : tests préalables, sauvegarde des configurations, documentation.

## 6. Jour 3 — Supervision, maintenance et Cluster Manager

### 6.1 Supervision et maintenance

Objectifs :

- configurer les outils de supervision ;
- planifier les tâches de maintenance ;
- mettre en œuvre les stratégies de sauvegarde et restauration.

Commandes de sauvegarde :

```bash
# Sauvegarde
mysqldump --all-databases > backup.sql
# Restauration
mysql < backup.sql
# Sauvegarde NDB
ndb_mgm -e "START BACKUP"
# Restauration NDB
ndb_restore -b <backup_id> -n <node_id>
```

Détection : échec de sauvegarde, données manquantes.

Mitigation : tests de restauration, automatisation des sauvegardes.

### 6.2 MySQL Cluster Manager

Objectifs :

- installer les agents et clients ;
- créer des clusters ;
- importer des configurations ;
- maintenir et gérer les clusters.

Détection : erreur de gestion, cluster inaccessible.

Mitigation : sauvegarde des configurations, documentation des procédures.

## 7. Jour 4 — Optimisation, réplication et tolérance aux pannes

### 7.1 Optimisation des performances

Objectifs :

- optimiser les paramètres de performance ;
- mettre en œuvre le sharding et le partitionnement ;
- diagnostiquer et résoudre les problèmes de performance.

Détection : latence élevée, temps de réponse lent.

Mitigation : optimisation des requêtes, indexation, partitionnement.

### 7.2 Réplication et tolérance aux pannes

Objectifs :

- configurer la réplication entre clusters ;
- gérer les pannes et les récupérations ;
- mettre en place les mécanismes de failover et failback.

Détection : nœud défaillant, basculement échoué.

Mitigation : redondance, tests de basculement, documentation des procédures.

## 8. Jour 5 — Sécuriser MySQL Cluster

### 8.1 Sécurité

Objectifs :

- sécuriser les connexions ;
- sécuriser les données ;
- sécuriser les nœuds serveurs.

Détection : connexion non autorisée, accès non chiffré.

Mitigation : chiffrement TLS, authentification forte, moindre privilège.

## 9. Format des preuves

```text
Date / heure :
Module :
Machine :
Outil :
Commande :
Résultat observé :
Capture / fichier :
Hash éventuel :
Limites :
```

Format d'un IOC :

```text
Type : ip | domaine | hash | chemin | compte | processus | requête
Valeur :
Contexte :
Première observation :
Dernière observation :
Faux positifs possibles :
Source :
```

## 10. Format de handoff

```text
Module :
Phase : rédaction | auto-test | correction | re-test
Version :
Objectif :
Périmètre :
Ce qui a été démontré :
Ce qui a été pratiqué :
Artefacts :
Self-test : passed | failed
Feedback traité :
Détections :
Mitigations :
Points de vigilance :
Question de vérification :
```

## 11. Erreurs fréquentes

- Configurer hors du réseau isolé du lab.
- Oublier le snapshot.
- Utiliser un mot de passe réel.
- Confondre configuration et risque métier.
- Fournir un livrable sans preuve.
- Documenter une configuration sans détection.
- Documenter une détection sans ID de référence.
- Proposer une mitigation non vérifiable.
- Laisser un service dangereux actif après le TP.
- Remettre un contenu non auto-testé.
- Supposer une connaissance non enseignée.
- Ignorer un feedback `blocker` ou `major`.
- Corriger sans versionner ni documenter.
- Modifier une commande sans refaire le self-test.

## 12. Règle finale

Une démonstration de configuration n'est valide que si elle est reproductible dans le lab, détectable,
corrigeable et rédigée selon le style commun (skill `common`, section 14) : français clair,
termes définis à la première occurrence, sortie attendue de chaque commande, aucune étape implicite.
Sinon, elle n'a pas sa place dans la formation.
