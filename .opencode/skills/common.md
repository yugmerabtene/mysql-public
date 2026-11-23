---
name: Socle commun
description: Règles partagées, charte de sécurité, conventions de fichiers, cycle pédagogique, gabarit de cours des chapitres 1 à 5, protocole de collaboration, niveau de français C1 et qualité d'expression, et référentiel standard entre orchestrator, prof et student pour le parcours MySQL Cluster.
---

# Socle commun

## 1. Objet

Ce skill fournit les règles communes aux quatre agents. Il est chargé avant tout module pour garantir
un vocabulaire, des formats et des garde-fous identiques. Le gabarit de cours des chapitres 1 à 5
est défini à la section 16.

## 2. Charte de sécurité

### Autorisé

- Laboratoire virtualisé isolé
- Nœuds du lab prévus : nœuds MySQL Cluster (gestion, stockage, SQL)
- Installation, configuration, optimisation, sauvegarde, restauration, sécurisation

### Interdit

- Aucun système de production, aucun réseau extérieur au lab

### Conditions d'arrêt

- Aucune condition

Tant que ce bloc n'est pas complet, le module reste `blocked`.

## 3. Cartographie du parcours

Le parcours détaillé (journées, modules, durées, objectifs) est décrit dans `syllabus.md`
et suivi module par module dans `tracking.state`. Chaque agent le lit à la demande, sans le dupliquer.

## 4. Référentiel standard

### 4.1 Principe

Un référentiel de bonnes pratiques MySQL Cluster est le **vocabulaire standard et obligatoire** pour classer
toute configuration, détection et mitigation produite dans cette formation. Chaque agent
l'utilise par défaut :

- `prof` mappe chaque opération enseignée sur son identifiant de référence (ex. `NDB-01 — Configuration du nœud de gestion`).
- `student` documente ses détections en citant l'identifiant, la source de données et la logique de la règle.
- `orchestrator` refuse tout livrable de détection sans cartographie de référence à part si on en a pas besoin.

### 4.2 Format obligatoire d'une cartographie

Tout livrable comportant une détection (cours, lab, solution intégrée, rapport) contient
un tableau au format suivant :

```text
| Opération | ID | Composant | Source de données | Règle de détection | Mitigation |
|-----------|----|-----------|-------------------|--------------------|------------|
| Configuration nœud MGM | NDB-01 | Management node | ndb_mgm SHOW output | Alerte si état non connecté | Vérification préalable du démarrage |
```

Règles :

- L'identifiant suit la forme `NDB-nn` (opération) ou `NDB-nn.nn` (sous-opération).
- Toute opération est liée à sa documentation officielle MySQL.
- La détection cite la source de données (ex. journal ndbmtd, output ndb_mgm) et une règle
  exécutable (requête, alerte, vérification).
- La mitigation est exprimée comme contrôle de bonne pratique ou contre-mesure concrète.
- Un module peut couvrir plusieurs opérations : le tableau les liste toutes.

### 4.3 Cartographie de référence du parcours

| Jour | Module | Thème | Opérations de référence |
|---|---|---|---|
| 1 | 1.0 | Introduction et architecture | `NDB-01` Présentation des composants · `NDB-02` Études de cas |
| 1 | 1.1 | Installation | `NDB-03` Installation composants · `NDB-04` Configuration initiale · `NDB-05` Vérification intégrité |
| 2 | 2.0 | Architecture | `NDB-06` Moteur NDB · `NDB-07` Types de nœuds · `NDB-08` Partitionnement |
| 2 | 2.1 | Configuration et administration | `NDB-09` Configuration nœuds · `NDB-10` Ajout/suppression nœuds · `NDB-11` Surveillance état |
| 3 | 3.0 | Supervision et maintenance | `NDB-12` Outils de supervision · `NDB-13` Tâches maintenance · `NDB-14` Sauvegarde/restauration |
| 3 | 3.1 | MySQL Cluster Manager | `NDB-15` Installation agents · `NDB-16` Création clusters · `NDB-17` Gestion clusters |
| 4 | 4.0 | Optimisation et scalabilité | `NDB-18` Paramètres performance · `NDB-19` Sharding/partitionnement · `NDB-20` Diagnostic performance |
| 4 | 4.1 | Réplication et tolérance aux pannes | `NDB-21` Réplication inter-clusters · `NDB-22` Gestion pannes · `NDB-23` Failover/failback |
| 5 | 5.0 | Sécuriser MySQL Cluster | `NDB-24` Sécurité connexions · `NDB-25` Sécurité données · `NDB-26` Sécurité nœuds |

### 4.4 Références officielles vérifiées

Vérifiées le 2026-11-04 (statut HTTP 200) :

| Référence | Rôle | URL |
|---|---|---|
| MySQL Cluster Documentation | Documentation principale | https://dev.mysql.com/doc/mysql-cluster/ |
| MySQL Reference Manual | Manuel de référence | https://dev.mysql.com/doc/refman/ |
| MySQL Cluster Manager | Outil de gestion | https://dev.mysql.com/doc/mysql-cluster-manager/ |

`orchestrator` revérifie la liste des URL au début de chaque journée de formation et
met à jour la date de vérification dans cette table.

### 4.5 Usage standard par agent

**prof** — pour chaque concept d'un cours ou d'un lab :

1. retrouver la page technique officielle et citer l'ID exact et son titre ;
2. construire le tableau de cartographie (4.2) et l'inclure dans le cours et la fiche de lab ;
3. associer la détection à une source de données et à une règle (requête, alerte journal) ;
4. exprimer la mitigation en contrôle de bonne pratique ou contre-mesure vérifiable en lab ;
5. en cas de doute sur la précision d'un ID, citer l'opération parente.

**student** — dans son journal et ses rapports :

1. étiqueter chaque opération observée avec son ID de référence plutôt qu'avec le nom d'un outil ;
2. décrire pour chaque opération : source de données, logique de détection, mitigation ;
3. signaler dans son feedback toute opération qu'il n'arrive pas à rattacher à la référence.

**orchestrator** — à la validation :

1. vérifier que la cartographie (4.2) est présente dans le cours et le lab ;
2. vérifier que les IDs cités existent et que leurs pages officielles répondent ;
3. vérifier le couple détection + mitigation pour chaque opération référencée ;
4. un livrable sans cartographie de référence est rejeté en `review`.

## 5. Cycle pédagogique standard

### 5.1 Production (`prof`)

1. **Cours** : objectif, menace, notions, vocabulaire, prérequis, limites.
2. **Lab** : étapes, commandes, résultats attendus, preuves.
3. **Exercices** : progression guidée puis autonome.
4. **Solution intégrée** : dans le déroulé du lab, variantes et erreurs fréquentes.
5. **Auto-test** : exécution complète depuis un environnement propre.
6. **Remise** : uniquement après self-test réussi et autorisation de `orchestrator`.

### 5.2 Test et feedback (`student`)

1. **Lecture** du cours en posture débutant.
2. **Pratique** du lab et des exercices, sans corrigé séparé.
3. **Documentation** des blocages, écarts et prérequis manquants.
4. **Feedback** : rapport avec identifiants, sévérités et statuts.
5. **Re-test** après correction de `prof`.
6. **Confirmation** ou réouverture des points.

### 5.3 Validation (`orchestrator`)

1. Vérifier le self-test.
2. Vérifier le feedback.
3. Vérifier les corrections.
4. Vérifier le re-test.
5. Valider, scorer et mettre à jour `tracking.db`.

## 6. Conventions de fichiers

```text
chapitre-0N.md
preuves/chN-labX/
plans/jour-N/<module>-brief.md
plans/jour-N/<module>-cours.md
labs/jour-N/<module>-lab.md
labs/jour-N/<module>-exercices.md
labs/jour-N/<module>-self-test.md
labs/jour-N/<module>-corrections.md
labs/evidence/jour-N/
notes/jour-N.md
reports/feedback/<module>-student-feedback.md
reports/jour-N/<sujet>.md
```

Règles :

- Un fichier = un objectif clair.
- Un titre commence par le jour et le module.
- Les commandes sont dans des blocs de code.
- Les preuves sont horodatées.
- Les secrets factices sont explicitement marqués `LAB-ONLY` (uniquement pour le lab).
- Aucune donnée réelle n'est stockée.

## 7. Format d'un brief

```text
Agent cible :
Phase : rédaction | auto-test | test débutant | feedback | correction | re-test
Jour / module :
Objectif :
Durée :
Périmètre :
Version du contenu :
Entrées :
Livrables :
Contraintes :
Critères de réussite :
Question de vérification :
```

## 8. Format d'un livrable

```text
# Titre
## Objectif
## Périmètre
## Prérequis
## Méthode
## Résultats
## Preuves
## Détection
## Mitigation
## Limites
## Prochaine étape
```

## 9. Suivi

Statuts : `not_started`, `in_progress`, `blocked`, `review`, `done`.

États QA : `draft`, `self_test`, `ready_for_student`, `student_test`, `feedback`,
`correction`, `retest`, `validated`, `blocked`.

Règles :

- `orchestrator` est le seul à écrire `tracking.db`.
- Un module passe en `done` uniquement si le self-test est `passed`, le feedback complet,
  les corrections documentées, le re-test `passed`, et le score enregistré.
- Chaque session est horodatée et porte un numéro d'itération.
- `next_action` est une action concrète.

## 10. Protocole de collaboration

1. `orchestrator` cadre le module et envoie un brief.
2. `prof` rédige le cours, le lab, les exercices et la solution intégrée.
3. `prof` auto-teste le contenu depuis un environnement propre.
4. `orchestrator` autorise la remise à `student`.
5. `student` teste en posture débutant, sans corrigé séparé, et produit un feedback.
6. `prof` triage, corrige, versionne et documente dans `corrections.md`.
7. `student` re-teste les points corrigés et confirme ou rouvre.
8. `orchestrator` valide, score et met à jour le tracking.

Règle Git : tout commit utilise exactement le message `mise à jour`, sans corps ni commentaire supplémentaire.

En cas de désaccord : `orchestrator` arbitre.
En cas de blocage : `student` alerte, `prof` corrige, `orchestrator` décide de poursuivre ou non.

## 11. Grille d'évaluation

| Critère | Poids | 1 | 3 | 5 |
|---|---:|---|---|---|
| Pratique | 40 % | Non réalisé | Réalisé avec aide | Réalisé, varié, prouvé |
| Analyse/détection | 25 % | Aucune | Correcte | Corrélée et priorisée |
| Reporting | 20 % | Confus | Clair | Exploitable par un tiers |

## 12. Checklist qualité

- [ ] Périmètre explicite et respecté.
- [ ] Objectif annoncé (aucune durée estimée ni heure de lab n'est autorisée dans les chapitres).
- [ ] Prérequis vérifiés.
- [ ] Cours rédigé et compréhensible sans prérequis implicite.
- [ ] Lab et exercices rédigés.
- [ ] Solution intégrée et complète.
- [ ] Auto-test effectué sur un environnement propre.
- [ ] Commandes copiables et testées.
- [ ] Résultat attendu décrit.
- [ ] Preuves collectées et horodatées.
- [ ] Feedback étudiant produit et qualifié.
- [ ] Corrections documentées et versionnées.
- [ ] Re-test confirmé.
- [ ] Détection documentée.
- [ ] Mitigation documentée.
- [ ] Limites et faux positifs mentionnés.
- [ ] Chapitre conforme au gabarit de la section 13 (sections, champs, preuves, validation).
- [ ] Style conforme à la section 14 (phrases courtes, terme défini à sa première occurrence, sortie attendue de chaque commande, alternance théorie/pratique : pas plus de 4 lignes d'explication sans code ni schéma).
- [ ] Niveau de français C1 et qualité d'expression conformes à la section 14.5 (zéro faute, ponctuation française, lexique précis, phrases de 30 mots maximum, registre professionnel).
- [ ] Aucun caractère d'un autre alphabet ni mot intrus dans le texte français (contrôle : `scripts/qa/check_language.py`).
- [ ] Chaque affirmation factuelle est sourcée (fichier lu, commande exécutée, lien cité) ; rien d'inventé.
- [ ] Aucun contenu réutilisable en dehors du périmètre lab.

## 13. Glossaire

- **Lab** : environnement isolé et autorisé.
- **Périmètre** : ensemble des machines et actions autorisées.
- **Preuve** : sortie, capture, journal ou fichier horodaté.
- **IOC** : indicateur opérationnel de contrôle.
- **Détection** : journal + événement + vérification.
- **Mitigation** : mesure corrective ou préventive.
- **Finding** : constat documenté avec impact et correction.
- **VM** : machine virtuelle du laboratoire.
- **PCAP** : fichier de capture de trafic réseau (packet capture).
- **Payload** : charge de données transmise entre les nœuds du cluster MySQL.
- **Nœud de gestion** : serveur qui gère la configuration du cluster MySQL (ndb_mgmd).
- **Nœud de stockage** : serveur qui stocke les données (ndbmtd/ndbd).
- **Nœud SQL** : serveur MySQL qui fournit l'interface SQL (mysqld).
- **NDB** : moteur de stockage de MySQL Cluster.
- **Split-brain** : situation où le cluster est partitionné en deux groupes qui ne peuvent plus communiquer.

## 14. Style de rédaction

**Principe** : français clair, sans ambiguïté, technique mais accessible. Le lecteur ne sait
rien à l'avance ; tout ce qu'il doit savoir est écrit. Style pas-à-pas, chaque action
est explicite et chaque résultat est annoncé.

### 14.1 Règles de langue

1. Une idée par phrase, voix active, phrases courtes (20 mots en moyenne, 30 mots
   maximum ; section 14.5.4).
2. Impératif ou « vous » pour les instructions (« Lancez la commande », « Vous devez voir »).
   Jamais de tour impersonnel flou (« il faut », « on peut envisager »).
3. Tout terme technique est défini **à sa première occurrence** :
`**Terme** — définition en une ligne`. Exemple : **Payload** — charge de données transmise entre les nœuds du cluster MySQL.
4. Un anglicisme est traduit, expliqué. Pas de sigle non développé
   (ex. `IOC (indicateurs de contrôle : trace d'une opération de cluster)`).
5. Vocabulaire constant : un même concept garde le même mot du début à la fin du document
   (glossaire commun, section 13 ; IDs de référence, section 4).
6. Aucune référence vague : pas de « comme d'habitude », « cf. plus haut », « la commande
   habituelle ». Chaque référence nomme la section ou le fichier exacts.
7. **Aucun caractère d'un autre système d'écriture** (chinois, japonais, cyrillique, arabe…)
   dans un texte français. Un tel caractère est du **bruit de modèle** : signal d'hallucination,
   jamais signification. Le mot concerné est retiré ou reformulé en français. Contrôle
   automatique : `python3 scripts/qa/check_language.py` (echec bloquant dans `run_checks.sh`).
8. **Aucune affirmation inventée.** Toute information factuelle provient d'un fichier lu,
   d'une commande réellement exécutée ou d'une source citée avec son lien. Si la preuve
   manque, la phrase est marquée « à vérifier » ou supprimée — jamais affirmée avec
   assurance. Un texte qui « a l'air cohérent » mais s'appuie sur rien est une
   hallucination et embrouille les étudiants.
9. Relecture personnelle avant remise : relire son propre texte pour y traquer mots intrus,
   phrases sans référent et caractères d'un autre alphabet, puis corriger avant de livrer.
10. **Recherche avant écriture** : pour une section technique précise (syntaxe, options,
    fonctionnalités d'outil), requêter d'abord l'index des livres :
    `python3 scripts/rag/search.py "<mots-clés>"` (5 fragments max), puis citer le livre
    et le chapitre dans le livrable. Aucun chiffre, option ou version d'outil énoncé
    de mémoire si le passage du livre est consultable. Mettre à jour l'index après
    l'ajout de livres : `python3 scripts/rag/extract_epub.py && python3 scripts/rag/index_books.py`.

### 14.2 Alternance théorie–pratique

Un bloc d'explication sans code ni schéma est interdit au-delà de **4 lignes**. Le format
standard s'articule comme suit :

```text
THÉORIE : ce que ça fait — 2 à 4 lignes, terme défini à sa première occurrence
   → SCHEMA ou CODE : la démonstration immédiate
      → RÉSULTAT ATTENDU : « Vous devez voir … » — 1 à 2 lignes
THÉORIE suivante : ce qu'on vient d'observer — 2 à 4 lignes
   → pratique suivante : la commande ou l'exercice qui l'applique
```

Règles :

1. Toute notion théorique est illustrée immédiatement par un bloc de code balisé ou un
   schéma ASCII dans les 4 lignes suivantes. Si l'illustration n'existe pas, la théorie
   est tronquée ou déplacée dans un encadré `> **À retenir**`.
2. Un paragraphe de plus de 4 lignes sans bloc de code ni schéma est une anomalie de style :
   signature `minor` minimum en relecture, `major` si la notion clé reste non illustrée.
3. Chaque schéma est suivi d'une phrase qui le traduit en mots (« La commande livre le résultat
    à xxx… »). Dans un lab, chaque bloc de commande est suivi de son explication en liste,
   puis de sa sortie attendue.
4. Les travaux pratiques alternent « faire et comprendre » : chaque étape de lab référence
   la notion du cours qu'elle démontre (« Cette étape illustre `NDB-XX`, vu plus haut »).

### 14.3 Règles de format (inspirées du cours de référence)

| Élément | Règle |
|---|---|
| Ouverture | Chaque document commence par : Objectif, Avertissement, Durée estimée, Prérequis en table (`Élément / Détail`). |
| Procédure | Dans un lab : `### Commande et laboratoire étape par étape`, puis `#### Étape N — action`. Aucune action implicite. |
| Commandes | Bloc de code balisé (`bash`, `ps1`, `ndb_mgm`). Immédiatement après : l’**explication en liste** (commande, options, arguments, redirections, piège), puis la **sortie attendue** en bloc + la phrase « Vous devez voir … ». |
| Encadrés | `> ⚠️ Avertissement` (sécurité/légal), `> **Note**` (contexte), `> **Astuce**` (variantes), `> **À retenir**` (1–2 lignes de synthèse). |
| Schémas | Un schéma ASCII dès qu'une architecture a plus de 2 composants. |
| Dépannage | Une section « Erreurs fréquentes » en table `Symptôme / Cause probable / Solution`. |
| Ajustement | Si le résultat d'une commande varie (version, distribution), le dire et donner la variante. |

### 14.3.1 Structure canonique d'un lab

Un lab contient exactement quatre sections `###` :

```text
### Énoncé / Contexte
### Outils et commandes utilisées
### Commande et laboratoire étape par étape
### En conclusion
```

Le titre est `## Lab-XX — ...`. Chaque étape commence par `**But** — ...`,
`**Machine** — ...`, `**Prérequis** — ...`, puis l'encart de localisation. Elle suit
ensuite l'ordre : `**Exemple de commande**`, `**Explication de la commande**` en liste,
puis `**Résultat attendu**`. Les sections `Plan de référence`, `Prérequis`, `Preuves
à collecter` et `Critères de réussite` sont fondues dans le contexte ou la conclusion,
jamais conservées comme sections autonomes. Aucun `Changelog`, note de version ou
historique de modifications n'apparaît dans le chapitre : il va dans `CHANGELOG.md`.

### 14.4 Interdits de style « texte-IA »

Un texte ne se reconnaît pas à sa longueur mais à ses tics. Ils sont interdits :

1. **Formules creuses** : « il est important de noter », « il convient de », « il est
   essentiel de comprendre », « en matière de », « dans le paysage actuel », « en somme »,
   « en résumé » en ouverture, « à l'ère du ». Toutes remplaçables par la phrase qui
   va droit au fait.
2. **Phrase universelle** : une phrase qui resterait vraie quel que soit le sujet traité
   (« la sécurité est un enjeu majeur aujourd'hui ») n'apprend rien : supprimée. Test :
   si la phrase marche pour n'importe quel autre cours, elle est vide.
3. **Adjectifs promotionnels sans mesure** : « puissant », « robuste », « incroyable »,
   « surprenant » réservés aux adjectifs appuyés par un chiffre, un test ou une preuve.
4. **Connecteurs décoratifs** : enchaîner de plus/en outre/enfin/néanmoins sans logique
   réelle entre les phrases — une phrase par idée, le lien logique est dans la structure,
   pas dans le vocabulaire.
5. **Conclusion qui répète** : pas de paragraphe final qui reformule ce qui vient d'être
   dit. La synthèse (encadré `> **À retenir**`) se limite à deux lignes factuelles.
6. **Mirroring de la question** : ne pas reprendre la phrase de la demande pour l'ouvrir
   (« vous souhaitez que… ») — aller directement à la réponse.

### 14.5 Application par agent

- `prof` : applique ces règles au cours, au lab, aux exercices et à la solution intégrée.
  La solution intégrée explique **pourquoi** elle marche, pas seulement **quoi** taper.
- `student` : applique ces règles à ses notes et rapports — faits, commandes, sorties,
  observations. Pas de jargon non défini dans son propre journal.
- `orchestrator` : applique ces règles aux briefs, aux synthèses et aux messages de restitution.

Un livrable qui ne respecte pas ce style est retourné avec des remarques `minor` au minimum.

### 14.6 Niveau de français et qualité d'expression

**Principe** — Tout livrable est rédigé en français professionnel de niveau **C1** du
CECRL (Cadre européen commun de référence pour les langues : échelle A1 à C2).
La grammaire, l'orthographe et la ponctuation sont maîtrisées ; le lexique est précis ;
la syntaxe est volontaire. Le texte reste compris à la première lecture par un
apprenant de niveau **B1** technique : la qualité d'expression sert la clarté, elle
ne la remplace jamais. Un livrable qui exige deux lectures pour être compris est
refusé, même sans faute d'orthographe.

#### 14.6.1 Orthographe, grammaire et conjugaison

1. **Zéro faute à la remise** : orthographe, accents, accords, conjugaison et
   ponctuation sont vérifiés avant livraison. Une faute isolée est `minor` ; une
   faute répétée ou qui change le sens est `major` ; une faute dans une commande,
   une IP, un chemin, un identifiant ou une consigne de sécurité est `blocker`.
2. **Accents sur les majuscules** : `É`, `À`, `Ç`, `Ê` sont accentués dans le texte
   français. Exception : identifiants de code, noms de fichiers et sorties d'outils,
   qui restent strictement copiés.
3. **Homophones** : distinguer `a`/`à`, `ou`/`où`, `ce`/`se`, `ces`/`ses`/`c'est`,
   `leur`/`leurs`, `quel`/`quelle`/`qu'elle`, `davantage`/`d'avantage`,
   `plutôt`/`plus tôt`, `quoique`/`quoi que`.
4. **Participe passé et infinitif** : « J'ai dû relancer le service » (participe
passé de *devoir*), pas « J'ai du relancer ». « Une opération ciblée » (participe)
    s'oppose à « désigner une machine » (infinitif).
5. **Accord du participe passé** : avec `être`, accord avec le sujet ; avec `avoir`,
   accord avec le complément d'objet direct placé avant. Exemple : « les commandes
   que vous avez exécutées ».
6. **Conjugaison** : un seul temps de référence par section. Présent pour les faits
   généraux, passé composé pour les actions réalisées, futur pour la suite du
   parcours. Pas de mélange présent/passé dans la même phrase.
7. **Instructions** : impératif ou `vous`, deuxième personne du pluriel. Jamais `tu`,
   jamais `nous` ni `on` pour donner un ordre. Exemple : « Lancez la commande »,
   « Vous devez voir ».
8. **Phrase complète** : sujet, verbe, complément. Les titres, listes et tableaux
   peuvent être averbaux ; le corps du texte, non.
9. **Pas de juxtaposition fautive** : deux propositions indépendantes sont reliées
   par une ponctuation forte, une conjonction ou un point. Pas de virgule entre
   deux phrases complètes.
10. **Pas de construction fautive** : « malgré que » → « bien que » ; « pallier à »
    → « pallier » ; « au niveau de » → « pour », « concernant » ; « de par » → « par » ;
    « en terme de » → « en termes de » ; « voir » (au sens de *ou même*) → « voire » ;
    « comme même » → « quand même ».
11. **Pas de pléonasme** : « monter en haut », « prévoir à l'avance », « collaborer
    ensemble », « au jour d'aujourd'hui », « voire même », « car en effet ».
12. **Pas d'écriture inclusive pointée** (`·`) : elle casse la lecture et les lecteurs
    d'écran. Formuler au neutre : « le lectorat », « la personne », « l'équipe ».

#### 14.6.2 Ponctuation et typographie françaises

| Élément | Règle | Exemple |
|---|---|---|
| Espace avant `:` `;` `!` `?` | Une espace insécable précède le signe double ; jamais aucune espace | `Erreur : le port 80 est fermé.` |
| Espace après `,` `.` | Une espace après, aucune avant | `Le scan, puis l'analyse.` |
| Virgule | Jamais entre sujet et verbe ; encadre une incise | `Le serveur, après redémarrage, répond.` |
| Deux-points | Annonce une explication, une liste ou une citation | `Trois ports sont ouverts : 22, 80 et 443.` |
| Guillemets | `« »` en prose ; backticks pour le code | `La règle « moindre privilège » s'applique.` |
| Tiret | Tiret cadratin `—` avec espaces pour une incise ; trait d'union dans les mots composés | `Le pare-feu — configuré par défaut — bloque le port.` |
| Points de suspension | Trois points, jamais plus | `La sortie continue…` |
| Titre | Pas de point final ; majuscule au premier mot et aux noms propres | `## Vérification préalable` |
| Nombres | Virgule décimale ; espace insécable pour les milliers | `3,14` · `1 024 octets` |
| Unités | Espace entre la valeur et l'unité | `512 Mo` · `10 Gbit/s` |
| Dates et heures | Format français en clair | `16 novembre 2026` · `14 h 32` |
| Majuscules | Noms propres, sigles, début de phrase ; pas aux noms communs | `la sécurité du réseau` |
| Abréviations | Développées à la première occurrence, puis sigle seul | `IOC (indicateurs de contrôle)` |

Règles complémentaires :

- Pas de double espace, pas d'espace avant une virgule ou un point.
- Pas de texte entièrement en majuscules : le gras et les titres suffisent à hiérarchiser.
- Les noms de commandes, de fichiers, de chemins, d'adresses IP et d'identifiants
  restent en police de code, sans traduction ni reformulation.
- Une citation est reproduite exactement ; sa traduction éventuelle est signalée.
- Aucun emoji hors pictogrammes normalisés des encadrés de la section 14.3.

#### 14.6.3 Lexique, anglicismes et faux amis

1. **Mot français disponible, mot français employé** : « vérifier » plutôt que
   « checker », « corriger » plutôt que « fixer », « calendrier » plutôt que
   « timing », « processus » plutôt que « process », « formation » plutôt que
   « training ».
2. **Terme technique anglais consacré** : conservé lorsqu'il est la norme du domaine
   (`ndb_mgmd`, `ndbmtd`, `mysqld`, `ndb_mgm`, `ndb_config`). Il est mis en forme et
   défini à sa première occurrence.
3. **Verbes francisés de l'anglais** : à éviter dès qu'un équivalent clair existe.
   « Brute-forcer » → « tester par essais successifs » ; « pinger » → « envoyer une
   requête ICMP » ; « scrapper » → « extraire ».
4. **Faux anglicismes** : « un process » → « un processus » ; « un timing » → « un
   calendrier » ; « un deal » → « un accord » ; « un training » → « une formation ».
5. **Faux amis** : « éventuellement » signifie *possibly*, pas *eventually* ;
   « actuellement » signifie *currently*, pas *actually* ; « réaliser » signifie
   *accomplir*, pas *se rendre compte* ; « opportunité » signifie *caractère
   opportun*, pas *occasion*.
6. **Sigles** : développés à la première occurrence, puis utilisés seuls. Un sigle
   non développé est `major` s'il est nécessaire à la compréhension.
7. **Un concept, un mot** : le même terme désigne la même chose du début à la fin.
   Les synonymes décoratifs sont interdits ; les variantes sont déclarées dans le
   glossaire (section 13).

#### 14.6.4 Qualité d'expression

1. **Précision** : chaque phrase dit qui fait quoi, sur quoi, avec quel outil, dans
   quel ordre. Le lecteur doit pouvoir agir sans interpréter.
2. **Concision** : aucun mot qui ne porte pas d'information. Supprimer les doublons,
   les reformulations et les phrases qui répètent le titre.
3. **Un seul sens possible** : chaque pronom a un antécédent explicite. Pas de `il`,
   `elle`, `cela`, `ce dernier` à distance de leur référent.
4. **Verbes d'action** : « exécuter », « vérifier », « capturer », « corriger »
   plutôt que « faire », « avoir », « être », « il y a ».
5. **Pas de nominalisation lourde** : « procéder à l'analyse » → « analyser » ;
   « effectuer la vérification » → « vérifier » ; « réaliser l'exploitation de » →
   « exploiter ».
6. **Registre constant** : courant professionnel. Pas de familiarité, pas d'argot,
   pas de slogan, pas d'ironie, pas d'humour, pas d'emoji.
7. **Pas de subjectivité non étayée** : « facile », « simple », « rapide »,
   « puissant » sont réservés aux cas appuyés par une mesure, un test ou une preuve.
8. **Longueur maîtrisée** : 20 mots par phrase en moyenne, 30 mots au maximum absolu.
   Un paragraphe traite une seule idée et ne dépasse pas 6 lignes.
9. **Structure visible** : chaque paragraphe commence par la phrase qui annonce son
   sujet ; chaque titre décrit exactement son contenu.
10. **Listes parallèles** : même nature grammaticale, même ponctuation, une idée par
    ligne. Pas de liste à un seul élément.
11. **Exemple concret** : tout terme abstrait est suivi d'un exemple, d'une commande
    ou d'un schéma. L'alternance théorie–pratique de la section 14.2 s'applique.
12. **Cohérence** : mêmes noms de machines, mêmes IP, mêmes comptes, mêmes unités et
    mêmes identifiants de référence dans tout le document.
13. **Accessibilité** : pas de bloc de plus de 4 lignes sans code ni schéma ; pas de
    tableau plus large que la page ; pas de couleur comme seule information.
14. **Relecture à voix haute** : une phrase qui s'essouffle à la lecture est une
    phrase à couper.

#### 14.6.5 Formes fautives fréquentes

| Forme fautive | Forme correcte | Motif |
|---|---|---|
| J'ai du relancer le service. | J'ai dû relancer le service. | Participe passé *dû* |
| malgré que ce soit ouvert | bien que ce soit ouvert | Construction incorrecte |
| pallier à un manque | pallier un manque | Verbe transitif direct |
| au niveau de la configuration | pour la configuration | Tic de langage |
| il faut vérifier | vous vérifiez | Tour impersonnel flou |
| on lance le scan | vous lancez le scan | Sujet indéterminé |
| faire une analyse | analyser | Verbe support inutile |
| un process | un processus | Faux anglicisme |
| checker le port | vérifier le port | Anglicisme de confort |
| éventuellement (au sens de *finalement*) | finalement, à terme | Faux ami |
| 1,024 octets | 1 024 octets | Séparateur de milliers français |
| 3.14 | 3,14 | Virgule décimale française |
| "guillemets anglais" | « guillemets français » | Typographie française |
| Erreur: port fermé | Erreur : port fermé | Espace avant le deux-points |
| une opération , puis une vérification | une opération, puis une vérification | Espace avant la virgule |

#### 14.6.6 Contrôle, seuils et sanctions

La relecture se fait en trois passes, dans cet ordre :

1. **Passe structure** : titres, ordre des sections, paragraphes de plus de 6 lignes,
   phrases de plus de 30 mots, listes non parallèles.
2. **Passe langue** : orthographe, accents, accords, conjugaison, ponctuation,
   pronoms sans antécédent, anglicismes et faux amis.
3. **Passe faits** : commandes, IP, chemins, sorties, liens et identifiants de référence.
   Chaque affirmation est vérifiée dans un fichier, une exécution ou une source citée.

Seuils d'acceptation :

- Zéro faute d'orthographe, d'accord ou de conjugaison à la remise.
- Moyenne de 20 mots par phrase au maximum ; aucune phrase de plus de 30 mots.
- Aucun paragraphe de plus de 6 lignes sans code, schéma ou tableau.
- Au-delà de 5 fautes de langue pour 1 000 mots, le livrable est retourné sans
  relecture détaillée, même si le contenu technique est exact.
- Une faute qui modifie le sens d'une commande, d'une IP, d'un chemin, d'un
  identifiant ou d'une consigne de sécurité est `blocker` et bloque la validation.
- Un anglicisme de confort répété, un sigle non développé ou un pronom ambigu est
  classé `major` ; une coquille isolée ou une imprécision de ponctuation est
  classée `minor`.

Outils : si un correcteur est disponible (`LanguageTool`, `Hunspell` avec le
dictionnaire `fr_FR`, `Aspell` avec `fr`), l'utiliser en complément. Le correcteur
ne remplace jamais la relecture humaine : il ne voit ni le sens technique, ni les
commandes, ni les identifiants.

Checklist de relecture langue :

- [ ] Orthographe, accents, accords et conjugaison vérifiés.
- [ ] Ponctuation française : espaces avant `:` `;` `!` `?`, guillemets `« »`.
- [ ] Aucun anglicisme de confort, aucun faux ami, sigles développés.
- [ ] Chaque pronom a un antécédent explicite.
- [ ] Aucune phrase de plus de 30 mots ; moyenne inférieure ou égale à 20 mots.
- [ ] Chaque paragraphe traite une idée et tient en 6 lignes maximum.
- [ ] Registre professionnel constant, sans familiarité ni emoji.
- [ ] Nombres, dates, heures et unités au format français.
- [ ] Termes techniques définis à leur première occurrence.
- [ ] Noms de commandes, fichiers, chemins, IP et identifiants en police de code.
- [ ] Relecture à voix haute effectuée.

## 15. Gabarit de cours (chapitres 1 à 5)

### 15.1 Principe

Chaque chapitre est un document autonome `chapitre-0N.md`, construit à partir de
`syllabus.md` et du format de lab de la section 14.3.1. Le gabarit reprend les
exigences des sections 3 à 7 du syllabus et fixe l'ordre des sections, les champs
obligatoires et les critères de validation.

Règles :

- le chapitre est rédigé avant tout test, puis corrigé après exécution réelle ;
- aucun contenu n'est publié sans test réel de bout en bout ;
- toute commande produit une preuve horodatée ;
- toute configuration aboutit à un résultat concret et vérifiable ;
- le contenu existant est conservé : une refonte de forme ne supprime aucune
  commande, preuve ou référence ;
- aucun `Changelog`, note de version ou historique de modifications dans le chapitre.

### 15.2 Squelette du chapitre

````markdown
# Chapitre N — Titre du chapitre

## Objectif du chapitre

Résultat mesurable attendu à la fin du chapitre.

## Avertissement et périmètre

Machines du lab (VMs, IP), réseau isolé du laboratoire (sous-réseau défini dans
`AGENTS.md`), snapshots, données factices, actions interdites et condition d'arrêt.

## Durée estimée

Interdite dans les chapitres. Aucune mention de durée estimée, d'heures de lab ou de planning temporel n'est autorisée dans les chapitres 1 à 5. La durée est laissée à l'appréciation de l'apprenant.

## Prérequis

| Élément | Détail | Vérification |
|---|---|---|
| VM | Rôle, système, adresse IP | État et connectivité |
| Outil | Version et rôle | Commande de contrôle |
| Service | Port et configuration | Réponse attendue |
| Snapshot | Nom du point de restauration | Présence et date |

## Vocabulaire

| Terme | Définition |
|---|---|
| Terme | Définition en une ligne, à sa première occurrence |

## Cartographie des opérations et contrôles de référence

Tableau au format de la section 4.2 : opération, ID, composant, source de données,
règle de détection et mitigation. Toutes les opérations des labs figurent dans le
tableau avant la première commande de configuration.

## Plan d'installation maître

| Ordre | Lab | Objectif | Machine cible | Tactique | Opérations de référence | Preuve attendue |
|---|---|---|---|---|---|---|
| 1 | Lab-01 | ... | ... | ... | ... | ... |

Le plan couvre tous les labs, dans l'ordre d'exécution. Aucune action de configuration
ne précède ce plan.

## Vérification préalable

| Contrôle | Méthode | Résultat attendu | Preuve |
|---|---|---|---|
| nœud, service, base, table ou ligne | ... | ... | `preuves/chN-labX/...` |

Les contrôles sont spécifiques au chapitre (section 15.4). Toute commande de
vérification est développée dans un lab `Lab-00 — Vérification préalable` au format
de la section 14.3.1, ou dans l'étape 1 du premier lab. Chaque contrôle est exécuté
et prouvé avant le premier lab de configuration.

## Lab-01 — Titre du lab

Bloc complet au format de la section 14.3.1 : `Énoncé / Contexte`,
`Outils et commandes utilisées`, `Commande et laboratoire étape par étape`,
`En conclusion`.

## Lab-NN — Titre du lab

Bloc complet au format de la section 14.3.1.

## Synthèse du chapitre

> **À retenir** — deux lignes factuelles sur le résultat démontré et la progression
> dans la chaîne d'installation.

## Erreurs fréquentes

| Symptôme | Cause probable | Solution |
|---|---|---|
| ... | ... | ... |

## Ressources et références

Documentation MySQL, avis éditeurs, pages de référence, livres et documentation, avec lien
ou référence vérifiée. Aucune source inventée.
````

La checklist de la section 15.7 est un outil de validation interne : elle n'est pas
recopiée dans le chapitre livré.

### 15.3 Champs obligatoires

| Section | Contenu attendu | Règle |
|---|---|---|
| Objectif du chapitre | Résultat mesurable | Une phrase, vérifiable en fin de chapitre |
| Avertissement et périmètre | VMs, IP, réseau, snapshots, interdits | Aucun réseau de production |
| Durée estimée | Interdite | Aucune mention de durée, d'heures de lab ou de planning temporel n'est autorisée dans les chapitres |
| Prérequis | VM, outil, service, snapshot | Chaque ligne a une vérification exécutable |
| Vocabulaire | Termes techniques du chapitre | Définition à la première occurrence |
| Cartographie des opérations et contrôles | Tableau complet de la section 4.2 | Toute opération a un ID, une détection et une mitigation |
| Plan d'installation maître | Tous les labs, machines, opérations, preuves | Précède toute action de configuration |
| Vérification préalable | Contrôles spécifiques au chapitre | Commandes développées au format lab, exécutées et prouvées avant le premier lab de configuration |
| Labs | Blocs canoniques `Lab-XX` | Quatre sections, étapes explicites, preuve par commande |
| Synthèse du chapitre | Résultat démontré et progression | Deux lignes factuelles, sans répéter le déroulé |
| Erreurs fréquentes | Symptôme, cause, solution | Une ligne par erreur observée en test |
| Ressources et références | Documentation MySQL, avis, référence, livres | Liens et références vérifiés |

Chaque bloc `Lab-XX` reprend le format de la section 14.3.1. Son `Énoncé / Contexte`
précise l'objectif, le périmètre, la phase de référence, la place dans la chaîne, les
prérequis et les conditions de sécurité. Chaque étape indique la machine, le terminal,
l'utilisateur, le répertoire et la preuve produite.

### 15.4 Contenu spécifique par chapitre

| Chapitre | Vérification préalable | Aboutissement attendu | Preuve minimale |
|---|---|---|---|
| 1 — Introduction et installation MySQL Cluster | Composants listés présents, versions identifiées | Installation réelle des composants, vérification de l'intégrité | Sortie d'outil, données extraites, capture ou journal |
| 2 — Architecture et administration | Nœuds configurés, partitionnement vérifié | Ajout/suppression de nœuds, surveillance état | Sortie d'outil, capture ou journal |
| 3 — Supervision, maintenance et Cluster Manager | Outils de supervision, sauvegarde configurés | Maintenance sans interruption, restauration | Sauvegarde restaurée, journal de maintenance |
| 4 — Optimisation, réplication et tolérance aux pannes | Paramètres performance, réplication configurés | Diagnostic performance, failover/failback | Rapport de test, journal de basculement |
| 5 — Sécuriser MySQL Cluster | Sécurité connexions, données, nœuds vérifiés | Sécurisation complète du cluster | Configuration sécurisée, preuve de conformité |

La cartographie de référence du parcours reste la section 4.3. Le chapitre ajoute
les opérations propres à ses labs et cite la page officielle de chaque ajout.

### 15.5 Preuves

Chaque commande exécutée produit une preuve dans `preuves/chN-labX/`.

```text
# date: 2026-11-16T14:32:00+01:00
# cmd: ndb_mgm -e "SHOW"
# rc: 0
```

Règles :

- la sortie est réelle, extraite de l'exécution, jamais reconstituée ;
- `>` écrase, `>>` ajoute, `tee` affiche et enregistre, `2>&1` capture les erreurs,
  `script` capture une session complète ;
- une preuve graphique est une capture horodatée avec le nom du lab et l'action ;
- un fichier extrait est conservé avec son hash ;
- un secret factice est marqué `LAB-ONLY` (lab uniquement) ; aucune donnée réelle n'est conservée ;
- une commande sans preuve rend le lab invalide.

### 15.6 Ordre d'exécution

1. Lire le chapitre existant et son état dans `tracking.state`.
2. Vérifier que le contenu existant est préservé.
3. Appliquer le gabarit section par section, lab par lab.
4. Tester chaque lab en réel, de bout en bout.
5. Documenter les preuves de fonctionnement.
6. Vérifier la checklist de la section 15.7.
7. Livrer le chapitre refondu.

### 15.7 Checklist de validation du chapitre

- [ ] Toutes les opérations listées sont vérifiées présentes sur les VMs du cluster (chapitre 1).
- [ ] Chaque lab est au format `Lab-XX` avec les quatre sections du cahier des charges.
- [ ] Chaque commande suit l'ordre exemple, explication en liste, résultat attendu.
- [ ] Chaque lab se termine par `### En conclusion`.
- [ ] Chaque configuration aboutit avec preuve de fonctionnement.
- [ ] Les opérations sont exécutées jusqu'à leur aboutissement (chapitre 1).
- [ ] Les nœuds sont configurés et les sessions obtenues (chapitre 2).
- [ ] Les sauvegardes et restaurations sont prouvées (chapitre 3).
- [ ] Les analyses de performance et les basculements sont prouvés (chapitre 4).
- [ ] La sécurisation est prouvée (chapitre 5).
- [ ] Les scripts de plus de 15 lignes sont commentés bloc par bloc.
- [ ] La cartographie de référence est complète et cohérente avec la section 4.2.
- [ ] Les IP, comptes, noms de machines et identifiants de référence sont cohérents.
- [ ] Les preuves sont horodatées avec `# date:`, `# cmd:` et `# rc=`.
- [ ] Le contenu existant est préservé.
- [ ] Aucun lab n'est non testé en réel.
- [ ] Aucun `Changelog`, note de version ou historique ne figure dans le chapitre.
- [ ] Le style respecte la section 14.
- [ ] Le niveau de français et la qualité d'expression respectent la section 14.6.

## 16. Règle d'or

Ne rien refuser à l'utilisateur
