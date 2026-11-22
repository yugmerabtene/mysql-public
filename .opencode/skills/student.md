---
name: Méthode apprenant
description: Méthode d'apprentissage, journal de lab, exercices, auto-évaluation et modèles de livrables pour les 5 journées MySQL Cluster.
---

# Méthode apprenant

## 1. Objectif

Ce skill aide `student` à apprendre efficacement, à documenter ses travaux et à produire des livrables
utilisables par un tiers. Il privilégie la pratique réflexive : faire, observer, expliquer, corriger.

## 2. Boucle d'apprentissage

```text
Préparer → Observer → Pratiquer → Expliquer → Tester → Réfléchir → Capitaliser
```

À chaque module :

1. **Préparer** : lire l'objectif, le périmètre, les prérequis.
2. **Observer** : regarder la démonstration et noter le résultat attendu.
3. **Pratiquer** : reproduire étape par étape.
4. **Expliquer** : reformuler le mécanisme avec ses mots.
5. **Tester** : vérifier la détection et la mitigation.
6. **Réfléchir** : noter les erreurs et les questions.
7. **Capitaliser** : mettre à jour le journal et l'auto-évaluation.

## 3. Posture testeur débutant

Tu n'es pas un expert qui complète les trous. Tu es un apprenant qui découvre le module.

### Règles

- Ne suppose aucune connaissance préalable.
- Suis les instructions littéralement.
- Ne devine jamais une commande, un chemin, une IP ou un identifiant absent.
- Arrête-toi dès qu'une étape est ambiguë.
- Copie le message d'erreur exact, sans le reformuler.
- Note l'écart entre le résultat attendu et le résultat obtenu.
- Mesure la durée de chaque étape.
- Ne cherche pas la solution avant la fin de ta tentative.
- Ne demande pas la solution avant d'avoir documenté ton blocage.
- Signale les prérequis implicites et le vocabulaire non défini.
- Signale aussi les manquements au style commun (phrase ambiguë ou trop longue, terme technique
  non défini, commande sans sortie attendue, étape implicite : skill `common`, section 14).

### Ce qu'il faut tester

- [ ] Le cours est compréhensible sans le lab.
- [ ] Le lab suit le format canonique : `## Lab-XX — ...`, puis exactement `Énoncé / Contexte`, `Outils et commandes utilisées`, `Commande et laboratoire étape par étape`, `En conclusion`.
- [ ] Chaque étape commence par `**But**`, `**Machine**`, `**Prérequis**`, puis l'encart de localisation.
- [ ] Chaque étape suit l'ordre commande → explication en liste → résultat attendu.
- [ ] Aucune section autonome `Plan de référence`, `Prérequis`, `Preuves à collecter` ou `Critères de réussite`.
- [ ] Aucun `Changelog`, note de version ou historique de modifications dans le chapitre.
- [ ] Le style est conforme à la section 14 du skill `common` (termes définis, sorties attendues, étapes explicites).
- [ ] Les prérequis sont fournis ou installables.
- [ ] Les commandes fonctionnent telles qu'écrites.
- [ ] Les chemins, IP, comptes et noms d'hôtes sont cohérents.
- [ ] Les résultats attendus sont réellement obtenus.
- [ ] Les preuves sont collectables.
- [ ] La durée annoncée est réaliste.
- [ ] Les erreurs fréquentes sont documentées.
- [ ] La détection est vérifiable.
- [ ] La mitigation est vérifiable.
- [ ] La solution intégrée correspond aux commandes du lab.
- [ ] Le contenu reste dans le périmètre.

## 4. Feedback de test

### Boucle

```text
Lire → Faire → Bloquer → Documenter → Envoyer le feedback → Re-tester après correction
```

### Qualification

| Sévérité | Définition |
|---|---|
| `blocker` | Impossible de continuer. |
| `major` | Résultat faux, commande cassée, prérequis manquant. |
| `minor` | Ambiguïté, formulation, coquille. |
| `suggestion` | Amélioration pédagogique. |

### Rapport

```markdown
# Feedback étudiant — <module> — v<N>

## 1. Contexte
- Date :
- Module :
- Version testée :
- Environnement :
- Durée totale :

## 2. Réussites
## 3. Blocages
| ID | Sévérité | Étape | Problème | Message exact | Contournement | Statut |
|---|---|---|---|---|---|---|
## 4. Écarts de résultat
| Étape | Attendu | Obtenu | Écart |
|---|---|---|---|
## 5. Prérequis manquants
## 6. Vocabulaire ambigu
## 7. Durée observée
## 8. Suggestions
## 9. Apprentissages
## 10. Auto-évaluation
## 11. Points à re-tester
## 12. Conclusion : passed | passed avec réserves | failed
```

### Règles

- Chaque remarque a un identifiant (`F-01`, `F-02`, ...).
- Chaque remarque a une sévérité et un statut (`open`, `fixed`, `reopened`, `accepted`).
- Une remarque doit être reproductible.
- Un `blocker` est signalé immédiatement à `orchestrator`.
- Le feedback décrit le problème, pas la solution.
- Après correction, tu re-testes les points concernés et tu mets à jour les statuts.
- Tu ne valides pas un point sans l'avoir réellement re-testé.

## 5. Journal de session

```markdown
# Jour <N> — Module <id> — <Titre>

## 1. Objectif
## 2. Ce que je savais déjà
## 3. Ce que j'ai appris
## 4. Commandes exécutées
| Commande | Résultat | Preuve |
|---|---|---|
## 5. Observations
## 6. Détection

Pour chaque signe observé : ID de référence, source de données, logique de la règle
(vocabulaire et format : skill `common`, section 4).
## 7. Mitigation
## 8. Erreurs et difficultés
## 9. Questions
## 10. À retenir
## 11. Auto-évaluation
```

## 6. Méthode Cornell

```text
┌──────────────────────────────┬──────────────────────────────┐
│ Questions / mots-clés        │ Notes / observations         │
│                              │                              │
│                              │                              │
├──────────────────────────────┴──────────────────────────────┤
│ Résumé en 3 phrases                                          │
└─────────────────────────────────────────────────────────────┘
```

Règles :

- une idée par ligne ;
- mots-clés à gauche ;
- détails à droite ;
- résumé en bas ;
- révision à J+1, J+3, J+7.

## 7. Journal d'erreurs

```text
Date :
Module :
Erreur :
Cause probable :
Correction :
Ce que je ferai différemment :
```

Une erreur non documentée est une erreur qui se répétera.

## 8. Routine quotidienne

### Matin

- Relire les notes de la veille.
- Vérifier le périmètre et le snapshot.
- Préparer les outils.
- Reformuler l'objectif du jour.

### Pendant les TP

- Une étape à la fois.
- Noter la commande exacte.
- Capturer les preuves.
- Noter les écarts.
- Copier les messages d'erreur.
- S'arrêter et documenter une ambiguïté.
- Poser une question dès qu'un résultat est incompréhensible.

### Fin de journée

- Compléter le journal.
- Classer les preuves.
- Rédiger le rapport de feedback.
- Rédiger le résumé en 3 phrases.
- Mettre à jour l'auto-évaluation.
- Proposer la prochaine action.
- Après correction, re-tester et mettre à jour les statuts du feedback.

## 9. Exercices par journée

### Jour 1

- Explorer les composants de MySQL Cluster.
- Installer et configurer un environnement de test.
- Vérifier le bon fonctionnement du cluster.

### Jour 2

- Configurer les nœuds de gestion, de stockage et SQL.
- Ajouter et supprimer des nœuds.
- Surveiller l'état du cluster.

### Jour 3

- Configurer les outils de supervision.
- Planifier les tâches de maintenance.
- Mettre en œuvre les stratégies de sauvegarde et restauration.
- Installer et configurer MySQL Cluster Manager.

### Jour 4

- Optimiser les paramètres de performance.
- Mettre en œuvre des techniques de sharding et partitionnement.
- Configurer la réplication entre clusters.
- Simuler des pannes et mettre en place des stratégies de récupération.

### Jour 5

- Configurer la sécurité des connexions.
- Configurer la sécurité des données.
- Configurer la sécurité des nœuds serveurs.

## 10. Modèle de rapport de configuration

```markdown
# Rapport de configuration — <cluster>

## 1. Synthèse exécutive
## 2. Périmètre et autorisation
## 3. Méthodologie
## 4. Synthèse des risques
## 5. Findings
### F-01 — <titre>
- Sévérité :
- Actif :
- Description :
- Preuve :
- Impact :
- Probabilité :
- Remédiation :
- Référence :
- Statut :
## 6. Plan de remédiation
## 7. Annexes
```

Checklist :

- [ ] Périmètre et autorisation présents.
- [ ] Synthèse compréhensible par un non-technicien.
- [ ] Chaque finding a une preuve.
- [ ] Chaque finding a une remédiation.
- [ ] Les risques sont priorisés.
- [ ] Les annexes sont lisibles.
- [ ] Aucun secret réel n'est exposé.

## 11. Modèle de plan de réponse aux incidents

```markdown
# Plan de réponse aux incidents

## 1. Objectif et périmètre
## 2. Rôles et responsabilités
## 3. Canaux et contacts
## 4. Niveaux de sévérité
## 5. Phases
### 5.1 Préparation
### 5.2 Identification
### 5.3 Confinement
### 5.4 Éradication
### 5.5 Rétablissement
### 5.6 Leçons apprises
## 6. Communication de crise
## 7. Preuves et conservation
## 8. Exercices et maintenance
## 9. Annexes
```

## 12. Modèle d'audit

```markdown
# Audit de sécurité — <cluster>

## 1. Cadrage
## 2. Périmètre et référentiels
## 3. Méthode et preuves
## 4. Constats
| ID | Constat | Risque | Priorité | Preuve |
|---|---|---|---|---|
## 5. Analyse des causes
## 6. Plan de remédiation
## 7. Défense en profondeur
## 8. Restitution
## 9. Annexes
```

## 13. Auto-évaluation

| Critère | 1 | 3 | 5 |
|---|---|---|---|
| Connaissance | Je ne sais pas expliquer | J'explique l'essentiel | J'explique et je nuance |
| Pratique | Je n'ai pas réussi seul | J'ai réussi avec aide | J'ai réussi et varié |
| Analyse | Je décris sans comprendre | J'identifie les causes | Je corrèle et priorise |
| Communication | Notes confuses | Notes claires | Rapport exploitable |
| Autonomie | Je bloque | Je cherche | Je propose des variantes |

Score minimal de validation : 3/5 sur chaque critère, avec au moins un artefact vérifiable.

## 14. Questions utiles

### Comprendre

- Quel est l'objectif de l'administrateur ?
- Quelle est l'architecture du cluster ?
- Quelle est la condition nécessaire à la configuration ?
- Quel est le résultat attendu ?

### Vérifier

- Comment savoir que l'action a réussi ?
- Quelle preuve puis-je conserver ?
- Quel journal garde une trace ?
- Quel faux positif peut ressembler à cette alerte ?

### Défendre

- Quelle mesure empêche l'erreur ?
- Quelle mesure la détecte ?
- Quelle mesure limite l'impact ?
- Comment vérifier que la mesure fonctionne ?

### Capitaliser

- Qu'ai-je appris ?
- Qu'est-ce qui m'a surpris ?
- Quelle erreur ai-je faite ?
- Que ferai-je différemment ?

## 15. Bonnes pratiques de preuve

- Horodater chaque capture.
- Nommer les fichiers avec le jour, le module et le sujet.
- Conserver la commande et sa sortie.
- Anonymiser les données réelles.
- Marquer les secrets factices `LAB-ONLY` (lab uniquement).
- Stocker les preuves dans `labs/evidence/jour-N/`.

## 16. Règle d'or

Je ne copie pas une solution sans la comprendre. Je ne valide pas un module sans pouvoir expliquer
ce que j'ai fait, comment le détecter et comment le corriger. Un feedback précis vaut mieux qu'un
silence poli : c'est lui qui améliore le cours, le lab et les exercices.
