# Guide d'utilisation des agents (manuel)

OpenCode 1.19.5 ne charge pas automatiquement les agents depuis
`.opencode/agent/*.md`. Pour faire fonctionner le parcours, invoquez les
agents manuellement dans cette conversation.

## Rôles des agents

| Agent | Rôle | Quand l'invoquer |
|-------|------|------------------|
| `orchestrator` | Chef d'orchestre, valide, tient `tracking.db` et `tracking.state` | État des lieux, validation, prochaine action |
| `prof` | Rédige cours, lab, exercices et solution intégrée, auto-test | Rédaction d'un module |
| `student` | Teste en débutant, produit le feedback | Test débutant d'un module |
| `sysadmin` | Prépare l'infrastructure (serveurs, cluster, snapshots) | Déploiement du lab |

## Comment invoquer un agent

Dans votre message, précisez clairement l'agent et l'action :

- « orchestrator : fais l'état des lieux et donne la prochaine action »
- « prof : rédige le module 1.0 (cours, lab, exercices, solution intégrée) »
- « student : teste le module 1.0 en posture débutant, sans corrigé séparé »
- « sysadmin : déploie les serveurs et configure le cluster MySQL »

L'orchestrator ne délègue **jamais automatiquement**. C'est vous qui déclenchez
chaque étape, pour éviter les boucles vides.

## Vérifier l'état actuel

```bash
python3 scripts/orchestrator_cli.py
```

## Format canonique d'un lab (chapitres 1 à 5)

Chaque lab est un bloc autonome qui commence par un titre `## Lab-XX — Titre`.
Il contient exactement quatre sections de niveau `###`, dans cet ordre :

````markdown
## Lab-XX — Titre du lab

### Énoncé / Contexte

Objectif, périmètre, architecture MySQL Cluster, place dans la chaîne, prérequis et
conditions de sécurité. Les anciens blocs « Plan de référence » et « Prérequis »
sont fondus ici, pas conservés comme sections séparées.

### Outils et commandes utilisées

| Outil | Commande | Rôle |
|---|---|---|

### Commande et laboratoire étape par étape

#### Étape N — Action

**But** — objectif concret de l'étape, en une phrase.

**Machine** — machine source et cible, avec adresses IP.

**Prérequis** — état, service, port, snapshot ou outil nécessaire avant l'action.

> **Machine** : ... | **Terminal** : ... | **Utilisateur** : ... | **Répertoire** : ...

**Commande**

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

#### Étape N+1 — ...

### En conclusion

Synthèse en quelques phrases, puis les critères de réussite et le renvoi vers le
lab suivant. Les anciennes sections « Preuves à collecter » et « Critères de
réussite » sont fusionnées ici ou déplacées en annexe.
````

Règles du format :

- Le titre est `## Lab-XX — ...`, jamais `## 6. Lab-01 — ...`.
- Les quatre sections internes sont exactement `### Énoncé / Contexte`,
  `### Outils et commandes utilisées`, `### Commande et laboratoire étape par étape`,
  `### En conclusion`.
- Les sections `Plan de référence`, `Prérequis`, `Preuves à collecter` et
  `Critères de réussite` ne sont plus des sections autonomes dans le lab.
- Chaque étape commence par `**But** — ...`, `**Machine** — ...`,
  `**Prérequis** — ...`, puis l'encart de localisation, puis la commande.
- Chaque étape suit l'ordre : commande → explication en liste → résultat attendu.
- L'explication est une liste, pas un paragraphe : une ligne par commande, option,
  argument, redirection ou piège, avec l'effet à côté.
- Les scripts de plus de 15 lignes sont commentés bloc par bloc et introduits dans
  l'étape qui les utilise.
- Une commande, une preuve ou un identifiant de référence existant n'est jamais supprimé lors d'une
  refonte de forme.
- Aucun historique de version, bloc `Changelog`, note de révision ou liste de
  modifications dans `chapitre-0N.md` : le chapitre reste un document de cours.
  L'historique vit dans `CHANGELOG.md` à la racine du dépôt et dans les commits,
  tags et releases GitHub.

## Workflow par module

1. **Cadrer** — objectif, durée, périmètre, livrables
2. **Rédaction** — `prof` produit cours, lab, exercices et explications intégrées au format canonique, sans corrigé séparé
3. **Auto-test** — `prof` exécute en environnement propre
4. **Remise** — `orchestrator` passe le contenu à `student` (sans corrigé séparé)
5. **Test débutant** — `student` teste sans corrigé séparé, produit le feedback
6. **Feedback** — `orchestrator` qualifie (blocker / major / minor / suggestion)
7. **Correction** — `prof` corrige, documente, versionne
8. **Re-test** — `student` re-teste les points corrigés
9. **Validation** — `orchestrator` vérifie portes G0–G7, met à jour `tracking.db` et `tracking.state`

## Règles de rédaction des chapitres (chapitres 1 à 5)

Ces règles s'appliquent à **tous les chapitres**, sans exception.
Le gabarit complet du chapitre (sections, champs obligatoires, preuves, validation)
est défini dans `.opencode/skills/common.md`, section 16.

1. **Format canonique obligatoire** — chaque lab suit exactement la structure définie ci-dessous : titre `Lab-XX`, section `Énoncé / Contexte`, section `Outils et commandes utilisées`, section `Commande et laboratoire étape par étape`, section `En conclusion`. Aucune autre section `###` dans le corps du lab.
2. **Lab guidé, sans corrigé séparé** — l'énoncé et l'explication font partie du même déroulement. Il n'y a **pas de section « Corrigé » séparée** ni de question d'exercice détachée.
3. **Ordre d'une étape** — `**But**`, `**Machine**`, `**Prérequis**`, encart de localisation, Commande, puis explication décomposée en liste, puis résultat attendu. Le résultat ne précède jamais l'explication. Chaque étape indique la machine, le terminal, l'utilisateur, le répertoire et la preuve produite.
4. **Lab autoporteur** — un débutant doit pouvoir exécuter le lab sans deviner une commande, un chemin, une option ou un prérequis.
5. **Cohérence des identifiants** — les adresses IP, les noms de nœuds et les commandes doivent être identiques entre l'énoncé, les étapes et le plan maître.
6. **Fichier de sortie** — le chapitre est livré dans `chapitre-0N.md` (ex. `chapitre-01.md`), propre, fusionné et sans section de corrigé détachée.
7. **Preuve d'exécution obligatoire** — chaque commande exécutée dans un lab doit produire une sortie enregistrée dans un fichier de preuve (ex. `ndb_mgm -e "SHOW" | tee preuves/ch1-lab1/ndb.txt`, `commande > preuves/.../sortie.txt 2>&1`). Cette preuve alimente le journal d'exécution et le plan de référence. Adapter la technique au contexte : `>` pour écraser, `>>` pour ajouter, `tee` pour afficher et enregistrer, `script` pour capturer une session complète, `2>&1` pour inclure les erreurs et le code retour.
8. **Localisation explicite et transitions** — chaque étape commence par le bloc `**But**` / `**Machine**` / `**Prérequis**`, puis par un encart de localisation :
   `> **Machine** : ... | **Terminal** : ... | **Utilisateur** : ... | **Répertoire** : ...`
   À chaque changement de machine, de terminal, d'utilisateur ou de répertoire, un avertissement explicite précède la commande (ex. « Passage sur le nœud SQL en SSH », « Retour sur l'hôte », « Nouveau terminal root sur le nœud de gestion »). L'apprenant ne doit jamais deviner où la commande s'exécute.
9. **Architecture avant toute action** — la présentation de l'architecture MySQL Cluster, les objectifs, les prérequis et le plan d'installation maître précèdent la configuration, l'optimisation et l'exploitation. Aucune commande de configuration ne doit précéder le plan d'installation.
10. **Commandes commentées** — chaque commande est expliquée dans une liste décomposée : commande, options, arguments, redirections et piège courant. Une commande sans explication, ou un résultat placé avant l'explication, est un défaut bloquant.
11. **Configuration complète et preuve** — toutes les configurations et tous les scripts sont développés, exécutés et testés en réel dans le lab, sans limitation, sur les serveurs de laboratoire, avec snapshot/rollback, preuve horodatée. Aucune cible réelle, aucun réseau de production, aucune sortie Internet.
12. **Relecture globale** — avant et après chaque révision, l'agent relit tous les chapitres pour vérifier la cohérence des labellisations machine/terminal, des IP, des noms de nœuds et des renvois entre chapitres.
13. **Machine d'administration et exécution des labs** — sauf mention contraire explicite, tous les labs sont exécutés depuis la machine d'administration vers les nœuds du cluster. L'hôte ne sert que d'hyperviseur, de gestion des snapshots et de stockage/archivage des preuves. Le chapitre doit indiquer la machine, le terminal, l'utilisateur et le répertoire avant chaque commande ; les commandes de gestion VirtualBox sont réservées à l'hôte.
14. **Changelog hors chapitre** — aucun bloc `Changelog`, aucune note `Version x.y` et aucune liste de modifications dans les chapitres. Ces informations sont centralisées dans `CHANGELOG.md` et dans l'historique GitHub (commits, tags, releases).

## Règles Git

- Tout commit utilise exactement le message `mise à jour`.
- Aucun corps de commit, aucune note ni commentaire supplémentaire.
- Le `.gitignore` est respecté : aucun secret, aucune VM, aucun fichier de suivi local n'est versionné.

## Règles de délégation aux sous-agents

- Après chaque tâche déléguée à un sous-agent (`sysadmin`, `prof`, `student`), si les tests passent correctement et la validation est verte, procéder immédiatement à un commit (`mise à jour`) puis un push vers le dépôt distant.
- Aucun commit ni push si les tests échouent ou si la validation n'est pas verte.
- Tout sous-agent qui crée ou utilise une nouvelle clé, token ou mot de passe doit l'indiquer dans `.env` (jamais commit/push, jamais affiché en clair). L'agent principal vérifie que `.env` reste dans `.gitignore` avant tout push.

## Règle d'interdiction de réinstallation des VMs (règle absolue)

- **Jamais** réinstaller, recréer, supprimer ou réinitialiser une VM existante sans autorisation écrite et explicite de l'utilisateur.
- Si l'utilisateur indique que les VMs sont déjà installées et fonctionnent, utiliser les VMs existantes telles quelles et configurer uniquement ce qui est demandé (réseau, SSH, IPs statiques, snapshots).
- Avant toute action sur une VM, vérifier son état réel via `VBoxManage list vms` et `VBoxManage showvminfo <nom>`.
- Si une VM existe déjà avec un disque et un OS, ne pas attacher d'ISO d'installation, ne pas modifier l'ordre de boot pour forcer une réinstallation, ne pas recréer le disque VDI.
- Les disques des VMs doivent impérativement rester dans `/home/yug/Documents/mysql/vm/` — ne jamais déplacer, copier ou supprimer les fichiers `.vdi`, `.vbox`, `.vbox-prev` ailleurs.
- Toute violation de cette règle est un défaut bloquant qui doit être corrigé immédiatement.

## État actuel (tracking.state — lecture rapide des agents)

- Jour : 1 | Module : 1.x (chapitre 1) | Statut : en cours
- Infrastructure cible : 3 VMs (1 vCPU, 1 Go RAM, 15 Go disque, Ubuntu Server 24.04 LTS) sur réseau isolé vboxnet0 192.168.56.0/24.
  - VM 1 (192.168.56.10) : nœud de gestion (`ndb_mgmd` NodeId 1) + nœud SQL (`mysqld` NodeId 4)
  - VM 2 (192.168.56.11) : deux nœuds de stockage (`ndbmtd` NodeId 2 et 3)
  - VM 3 (192.168.56.12) : second nœud SQL (`mysqld` NodeId 5)
- Chapitre 1 v1.2 : introduction à MySQL Cluster, installation des composants, vérification de l'intégrité.

**Fichiers d'état :**
- `tracking.state` — état courant, lisible directement par tous les agents (clé:valeur, minimal).
- `tracking.db` — source de vérité durable, verrouillé, écriture seule par `orchestrator`.
- `tracking.json` — miroir détaillé (optionnel), ne pas lire en routine (trop volumineux).

## Débloquer le parcours

L'infrastructure de base est déjà déployée :
1. VirtualBox et le réseau isolé (vboxnet0, 192.168.56.0/24, DHCP désactivé) pour les nœuds du cluster MySQL.
2. Les VMs sont connectées uniquement au réseau du lab pendant les travaux pratiques.
3. IPs statiques : 192.168.56.10 (gestion + SQL NodeId 4), 192.168.56.11 (stockage x2 NodeId 2 et 3), 192.168.56.12 (second nœud SQL NodeId 5). Hôte : 192.168.56.1.
4. Prendre un snapshot propre de chaque VM avant manipulation. Garder l'accès Internet désactivé pendant les labs.
5. Pour le périmètre actuel, seuls les nœuds du cluster sont nécessaires. Maximum 3 VMs, idéalement 2.

## Vérification du .env obligatoire (tous les agents)

Avant **chaque** intervention, tout agent doit invoquer la skill `check-env` (`.opencode/skills/check-env/SKILL.md`) et lire le fichier `.env` à la racine du projet pour récupérer :
- `GITHUB_TOKEN` (authentification GitHub : création de repo privé, push).
- `GIT_AUTHOR_NAME / GIT_AUTHOR_EMAIL / GIT_COMMITTER_NAME / GIT_COMMITTER_EMAIL` (identité git).

Les infos VM (IP 192.168.56.10 gestion+SQL, 192.168.56.11 stockage x2, 192.168.56.12 second SQL) se lisent dans `tracking.state` et `tracking.db`.
**Interdit** de committer, push ou afficher en clair le contenu de `.env`. Le fichier est déjà ignoré par `.gitignore` (`# Secrets : .env`).
Avant tout `git push`, vérifier qu'aucun secret n'est présent dans les fichiers stagés.
