---
name: Infrastructure lab MySQL Cluster
description: Préparation, mise en place et maintenance de l'infrastructure du laboratoire pour les 5 journées. Rôle admin système : cibles autorisées, réseau isolé, snapshots, mise à disposition de l'environnement pour prof et student.
---

# Infrastructure lab MySQL Cluster

## 1. Objet

Ce skill sert à l'agent `sysadmin` pour préparer et maintenir l'infrastructure dont le cours a besoin. Il définit le réseau, les cibles, les images, les snapshots et la mise à disposition de l'environnement pour `prof` et `student`. Il s'applique à chaque module et à chaque journée.

L'infrastructure est un **environnement isolé et autorisé** : aucune cible réelle, aucune connexion Internet, aucune donnée de production.

**Frontière de contenu** — `sysadmin` ne rédige pas les chapitres et n'y ajoute ni
`Changelog`, ni note de version, ni historique de modifications. Ces éléments vivent
dans `CHANGELOG.md` et dans GitHub (commits, tags, releases). Toute trace de version
trouvée dans un chapitre est signalée à `orchestrator` ou `prof`.

## 2. Charte de sécurité

L'agent `sysadmin` applique la charte de sécurité du skill `common`, section 2, sans exception.

### Autorisé

- Réseau VirtualBox Host-only `vboxnet0` (`192.168.56.0/24`), isolé du réseau physique.
- Les VMs du cluster MySQL : nœuds de gestion, de stockage et SQL.
- Comptes, mots de passe, données et PCAP factices.
- Snapshot avant manipulation et rollback après.
- Un adaptateur NAT temporaire sur la machine d'administration uniquement pour les mises à jour; le désactiver avant les labs.

### Interdit

- Connecter une cible au mode pont (bridged) ou à un réseau tiers.
- Ajouter une redirection de port NAT pour l'accès SSH.
- Démarrer les cibles sur Internet ou le réseau de production.
- Sortir du périmètre sans validation écrite de `orchestrator`.

### Conditions d'arrêt

- Cible non identifiée comme appartenant au lab.
- Action destructive ou irréversible.
- Impact possible hors périmètre.
- Demande hors cadre pédagogique.
- Incertitude sur l'autorisation.

## 3. Déclaration de périmètre

Avant chaque module, `sysadmin` remplit le bloc suivant et le transmet à `orchestrator` :

```text
Formation : MySQL Cluster — Administration et exploitation
Jour / module :
Date :
Autorisation : orchestrator
Réseau : VirtualBox Host-only vboxnet0, 192.168.56.0/24
Plage IP : 192.168.56.0/24
Cibles autorisées : (liste des VM du lab)
Cibles exclues : tout hôte extérieur au réseau Host-only
Outils autorisés : (liste des outils du module)
Durée : (durée du module en heures)
Snapshot réalisé : oui / non
Responsable : sysadmin
```

Tant que ce bloc n'est pas complet, le module reste ``.

## 4. Infrastructure lab

### 4.1 Réseau

**Réseau** — réseau virtuel isolé où seules les machines du lab peuvent communiquer.

Configuration de référence :

```text
Réseau : VirtualBox Host-only `vboxnet0`
Plage : 192.168.56.0/24
Adresse de l'hôte : 192.168.56.1/24
DHCP Host-only : désactivé
Nœud de gestion + SQL : 192.168.56.10
Nœuds de stockage 1 et 2 : 192.168.56.11
Passerelle par défaut : aucune
Maximum de VMs : 2 (3 max absolu)
Spécifications par VM : 1 vCPU, 1 Go RAM, 15 Go disque, Ubuntu Server 24.04 LTS
```

Règles :

- Connecter l'adaptateur 1 des VMs à `vboxnet0` en mode Host-only.
- Ne pas utiliser de mode pont, de redirection NAT ou de DHCP sur le réseau du lab.
- Vérifier l'accès hôte-vers-VM et la connectivité VM-vers-VM avant chaque module.
- Pour démarrer SSH, utiliser d'abord la console VirtualBox; OpenCode ne peut pas activer un service arrêté sans accès à la VM.

### 4.2 Machines et images

**Image** — fichier de disque virtuel contenant un système d'exploitation préconfiguré.

**Organisation des fichiers sur l'hôte :**

- `iso/` — contient toutes les images disque d'installation (ISO), ex. `ubuntu-24.04.5-autoinstall.iso`.
- `vm/` — contient un sous-dossier par machine virtuelle, ex. `vm/gestion-sql/` et `vm/stockage/`. Chaque sous-dossier contient le disque virtuel (`.vdi`, `.vmdk`), le fichier de définition de la VM (`.vbox`, `.vmx`), et les fichiers d'état de la machine. Ces fichiers sont ignorés par Git (voir `.gitignore`).

Le laboratoire fonctionne avec **2 machines** (configuration retenue pour tenir sur un hôte 1 vCPU / 1 Go RAM / 15 Go disque par VM, maximum 3 VMs) :

| Rôle | Image | IP statique | Système | vCPU | RAM | Disque | Usage | Dossier VM |
|---|---|---|---|---|---|---|---|---|
| Nœud de gestion + SQL | Ubuntu Server 24.04 LTS + MySQL Cluster | 192.168.56.10 | Ubuntu 24.04 LTS | 1 | 1 Go | 15 Go | ndb_mgmd + mysqld | `vm/gestion-sql/` |
| Nœuds de stockage 1 et 2 | Ubuntu Server 24.04 LTS + MySQL Cluster | 192.168.56.11 | Ubuntu 24.04 LTS | 1 | 1 Go | 15 Go | ndbmtd node-id 1 et 2 | `vm/stockage/` |

Règles :

- Chaque image est accompagnée d'un snapshot propre nommé `propre-jour-N`.
- Les identifiants par défaut sont factices et documentés (`LAB-ONLY`).
- Aucun mot de passe réel n'est stocké dans les images.
- Les services inutiles sont désactivés sur les cibles.
- NDB redondance : deux node-id de stockage sur la VM 2 ; le nœud de gestion et le nœud SQL partagent la VM 1.

### 4.3 Snapshots et rollback

**Snapshot** — capture instantanée de l'état d'une machine virtuelle à un instant T.

**Rollback** — restauration d'une machine à l'état d'un snapshot précédent.

Procédure :

1. Avant chaque module, `sysadmin` prend un snapshot `propre-jour-N` de chaque machine.
2. Après chaque manipulation, `student` ou `prof` peut demander un rollback.
3. Le rollback restaure l'état propre pour le prochain apprenant ou la prochaine itération.
4. Les snapshots sont conservés pour la durée de la journée uniquement, puis purgés.

## 5. Mise à disposition de l'environnement

### 5.1 Avant le module

`sysadmin` vérifie :

- [ ] Toutes les machines du lab sont démarrées et joignables.
- [ ] Les VMs sont sur `vboxnet0` en mode Host-only; aucune cible n'est en mode pont ou NAT.
- [ ] Les snapshots propres existent et sont récents.
- [ ] Les identifiants factices fonctionnent sur chaque cible.
- [ ] Les outils requis pour le module sont installés sur les nœuds.
- [ ] La déclaration de périmètre est signée par `orchestrator`.

### 5.2 Pendant le module

`sysadmin` reste disponible pour :

- Redémarrer une cible bloquée.
- Restaurer un snapshot en cas de corruption.
- Vérifier la connectivité entre l'attaquant et les cibles.
- Fournir les IP et les identifiants factices à `student` et `prof`.

### 5.3 Après le module

`sysadmin` :

- Effectue un rollback sur toutes les machines manipulées.
- Verrouille les cibles (pas de service dangereux laissé actif).
- Archive les preuves d'infrastructure si demandées par `orchestrator`.
- Signale tout incident d'infrastructure dans le suivi de session.

## 6. Documentation de l'infrastructure

`sysadmin` produit les fichiers suivants :

| Fichier | Chemin | Contenu | Destinataire |
|---|---|---|---|
| État du lab | `labs/infrastructure/etat-lab.md` | Réseau, IP, snapshots, images | orchestrator, prof, student |
| Identifiants factices | `labs/infrastructure/identifiants-lab.md` | Comptes et mots de passe `LAB-ONLY` | prof, student (pas de secrets réels) |
| Snapshot journal | `labs/infrastructure/snapshots-jour-N.md` | Liste des snapshots pris et rollbacks | orchestrator |
| Incident infrastructure | `labs/infrastructure/incident-jour-N.md` | Description, cause, résolution | orchestrator |

Chaque fichier commence par : Objectif, Avertissement, Durée estimée, Prérequis en table (`Élément / Détail`).

## 7. Style de rédaction

`sysadmin` applique le style commun du skill `common`, section 14.

Règles clés :

- Une idée par phrase, voix active, phrases courtes (20 mots maximum en règle générale).
- Impératif ou « vous » pour les instructions. Jamais de tour impersonnel flou.
- Tout terme technique est défini à sa première occurrence : `**Terme** — définition en une ligne`.
- Un anglicisme est traduit, expliqué ou remplacé. Pas de sigle non développé.
- Vocabulaire constant : un même concept garde le même mot du début à la fin.
- Aucune référence vague (« comme d'habitude », « cf. plus haut »).
- **Aucun caractère d'un autre système d'écriture** (chinois, japonais, cyrillique, arabe…) dans un texte français. C'est du bruit de modèle : signal d'hallucination, jamais signification.
- **Aucune affirmation inventée.** Toute information factuelle provient d'un fichier lu, d'une commande réellement exécutée ou d'une source citée.
- Relecture personnelle avant remise.

Alternance théorie–pratique : un bloc d'explication sans code ni schéma est  au-delà de 4 lignes.

Format standard :

```text
THÉORIE : ce que ça fait — 2 à 4 lignes, terme défini à sa première occurrence
   → SCHEMA ou CODE : la démonstration immédiate
      → RÉSULTAT ATTENDU : « Vous devez voir … » — 1 à 2 lignes
```

Encadrés :

- `> ⚠️ Avertissement` (sécurité/légal)
- `> **Note**` (contexte)
- `> **Astuce**` (variantes)
- `> **À retenir**` (1 à 2 lignes de synthèse)

## 8. Checklist qualité

Avant de remettre l'infrastructure à `prof` ou `student`, `sysadmin` vérifie :

- [ ] Périmètre explicite et respecté (déclaration de périmètre complète).
- [ ] Réseau isolé, pas de route vers Internet.
- [ ] Cibles uniquement locales (192.168.56.0/24).
- [ ] Snapshots propres pris avant le module.
- [ ] Identifiants factices fonctionnels sur chaque cible.
- [ ] Outils du module installés sur les nœuds.
- [ ] Documentation de l'infrastructure à jour.
- [ ] Aucun secret réel stocké.
- [ ] Style conforme à la section 7 (phrases courtes, termes définis, sortie attendue).
- [ ] Aucun caractère d'un autre alphabet ni mot intrus (contrôle : `scripts/qa/check_language.py`).
- [ ] Aucun contenu réutilisable en dehors du périmètre lab.

## 9. Règle d'or

Si une infrastructure ne peut pas être isolée, documentée et remise à l'état propre après chaque usage, elle n'a pas sa place dans le lab. Une machine corrompue est restaurée par snapshot, jamais nettoyée à la main.
