---
name: check-env
description: Vérifie le fichier .env à chaque intervention pour récupérer les tokens/secrets (GITHUB_TOKEN, GIT_AUTHOR_*, GIT_COMMITTER_*) et les infos VM avant toute action. À invoquer en début de session par chaque agent. Interdit de committer ou d'exposer les secrets.
---

# Skill check-env — lecture obligatoire du .env

## Quand l'invoquer

En début de **chaque** intervention d'agent (orchestrator, prof, student, sysadmin), avant toute commande bash, édition ou push.

## Règle

1. Lire le fichier `.env` à la racine du projet (`/home/yug/Documents/mysql/.env`).
2. Exporter / utiliser les variables qui s'y trouvent :
   - `GITHUB_TOKEN` — authentification GitHub (création de repo privé, push).
   - `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_NAME`, `GIT_COMMITTER_EMAIL` — identité git pour les commits.
3. Les infos VM (IP 192.168.56.10 gestion+SQL, 192.168.56.11 stockage) se lisent dans `tracking.state` et `tracking.db` ; compléter avec `.env` si des secrets de connexion y sont définis.
4. **Ne jamais** committer, push ni afficher en clair le contenu de `.env`. Le fichier est déjà ignoré par `.gitignore` (`# Secrets : .env`).

## Vérification avant push

Avant tout `git push` :
- confirmer que `.env` est bien dans `.gitignore`;
- confirmer qu'aucun secret n'est présent dans les fichiers stagés (`git diff --cached --stat`).
