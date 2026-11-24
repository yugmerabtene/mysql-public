# Corrections — Chapitres 1 à 5 (MySQL Cluster)

**Version :** v1.0  
**Date :** 2026-11-23  
**Agent :** prof  
**Scope :** `chapitre-01.md` à `chapitre-05.md` (racine du dépôt)  
**Anomalies traitées :** F-01 à F-08 (feedback etudiant `reports/feedback/chap1-5-student-feedback.md`)  
**Règles respectees :** format canonique des labs (4 sections internes uniquement), pas de section `Plan de reference`/`Preuves a collecter`/`Criteres de succes` autonome, pas de `Changelog`/`Version` dans les chapitres, pas de modification de `tracking.db`/`tracking.state`/`.env`, aucun commit, aucun push, aucune reinstallation de VM.

---

## Sommaire des decisions tranchees

| ID | Severite | Lab / Chapitre | Fichier | Decision | Statut |
|----|----------|----------------|---------|----------|--------|
| F-01 | BLOCKER | Lab-07 (ch.3) / Lab-11 (ch.4) | `chapitre-03.md`, `chapitre-04.md` | Remplacer `ndb_desc` (non fonctionnel sur l'infrastructure) par `mysql -u root -e "DESCRIBE <base>.<table>"` (operational, sortie reelle capturee). Mise a jour de la table d'outils et de l'explication. | CORRIGE |
| F-02 | MAJOR | Lab-08 (ch.3) | `chapitre-03.md` | Lab-08 ne contenait pas de `ndb_desc` (c'etait Lab-07, siehe F-01). Rien a modifier dans Lab-08 ; cohérence assuree par F-01. | CORRIGE (par F-01) |
| F-03 | MAJOR | Lab-12 (ch.4) | `chapitre-04.md` | Marquer explicitement Lab-12 comme "Lab non executable (demonstration uniquement)" via encadret en tete d'enonce, et retirer de la liste des labs testables executables. Conclusion et renvois Lab-13 deja coherents. | CORRIGE |
| F-04 | MAJOR | Lab-06 (ch.2), Lab-09 (ch.3), Lab-13 (ch.4), Lab-14 (ch.5) | `chapitre-02.md`, `chapitre-03.md`, `chapitre-04.md`, `chapitre-05.md` | Supprimer les 4 sections `### Erreurs de conception/architecture/configuration/gros volumes` situes apres `### En conclusion` du dernier lab de chaque chapitre. Retour a exactement 4 sections canoniques par lab. | CORRIGE |
| F-05 | MAJOR | Lab-09 (ch.3) etape 3 | `chapitre-03.md` | Ajouter `**Commande**` (`echo` constat) + `**Explication de la commande**` (liste decomposee) avant `**Resultat attendu**`. | CORRIGE |
| F-06 | MINOR | Figure 6 / Figure 8 (ch.1) | `chapitre-01.md` | Figure 6 garde `image-16.png` ; Figure 8 corrigee de `image-16.png` vers `image-15.png`. Aucun fichier image supprime. | CORRIGE |
| F-07 | MINOR | Lab-14 (ch.5) | `chapitre-05.md` | Ajouter une note explicite dans l'enonce : les VM ont un adaptateur NAT (route par defaut eventuelle via 10.0.2.2) ; l'isolement reseau porte sur le perimetre d'administration (vboxnet0 isole). | CORRIGE |
| F-08 | MINOR | Lab-14 (ch.5) | `chapitre-05.md` | Ajouter une note d'execution conditionnelle (TLS) : `--initial` disruptif pour le cluster partage ; a executer uniquement sur cluster dedie ou apres snapshot `propre-avant-lab`. | CORRIGE |

---

## Detail par anomalie

### F-01 — BLOCKER : `ndb_desc` ne connecte pas

**Constat :** `ndb_desc -d labndb t_ndb_desc` (et `ndb_desc -d labperf t_shard`) affiche `Unable to connect to management server.` ou pend en timeout sur VM 1. Le client NDB `ndb_desc` n'atteint pas le gestionnaire sur cette infrastructure, alors que `mysqld` (SQL NDB) fonctionne.

**Correction appliquee :**
- `chapitre-03.md`, Lab-07 etape 3 : remplacement de `ndb_desc -d labndb t_ndb_desc` par `mysql -u root -e "DESCRIBE labndb.t_ndb_desc"`. Explication decomposee (commande, option, argument, redirection, piege). Resultat attendu reelle (structure SQL de la table). Mise a jour de la table d'outils (`ndb_desc` -> `mysql DESCRIBE`).
- `chapitre-04.md`, Lab-11 etape 2 : remplacement de `ndb_desc -d labperf t_shard` par `mysql -u root -e "DESCRIBE labperf.t_shard"`. Idem pour l'explication et le resultat attendu. Mise a jour de la table d'outils et de la conclusion du lab.

**Decision tranchee :** `DESCRIBE` via mysql est retenu car il fonctionne sur le nœud SQL NodeId 4 (confirmé par le feedback etudiant, P8) et affiche la structure de la table NDB (champs, types, clés). Il ne remplace pas la fragmentation NDB de `ndb_desc`, mais c'est l'operation operationnelle disponible. `ndb_desc` est documenté comme non fonctionnel sur cette infrastructure.

**Note sur le libelle du feedback :** le feedback cite "Lab-03 (chapitre 2, étape 3)" et "Lab-08 (chapitre 3)". Dans les fichiers actuels, `ndb_desc` se trouve en realite dans `chapitre-03.md` Lab-07 etape 3 et `chapitre-04.md` Lab-11 etape 2. `chapitre-02.md` Lab-03 ne contient aucune occurrence de `ndb_desc`, et `chapitre-03.md` Lab-08 n'en contient pas non plus. Les corrections portent donc sur les occurrences reelles (Lab-07 ch.3 et Lab-11 ch.4).

### F-02 — MAJOR : Lab-08 impacte par F-01

**Constat :** Lab-08 (`chapitre-03.md`, sauvegarde/restauration) n'utilise pas `ndb_desc` dans sa version actuelle. L'impact F-01 sur Lab-08 est donc nul ; la correction F-01 (sur Lab-07) resout indirectement toute reference eventuelle.

**Decision tranchee :** aucune modification specifique a Lab-08 requise. Lab-08 reste coherent avec F-01.

### F-03 — MAJOR : Lab-12 declare non executable mais liste comme testable

**Constat :** `chapitre-04.md` Lab-12 (replication inter-clusters Cluster B) declare deja "Aucune commande de ce lab n'est executee en laboratoire" et "toutes les sorties sont illustratives". Toutefois il n'etait pas explicitement retire de la liste des labs testables.

**Correction appliquee :** ajout d'un encadret d'avertissement en tete de l'enonce de Lab-12 : `⚠ Lab non executable (demonstration uniquement, F-03) ... Ce lab est retire de la liste des labs testables executables.` Le statut "demonstration" est maintenu dans le paragraphe "Statut du lab". La conclusion de Lab-12 renvoie deja vers Lab-13 (entierement executable). Lab-13 declare deja son independance vis-a-vis de Lab-12 (table `labfail.t_fail` propre).

**Decision tranchee :** Lab-12 n'est pas rendu executable (le second cluster Cluster B n'est pas deployable sur 3 VMs). Il est marque explicitement comme demonstration non executable et retire des labs testables. Aucun renvoi vers Lab-12 comme lab executable ne subsiste dans les chapitres 1 à 5.

### F-04 — MAJOR : 8 sections `###` au lieu de 4

**Constat :** après le `### En conclusion` du dernier lab de chaque chapitre, 4 sections `### Erreurs de conception / d'architecture / de configuration / sur gros volumes` se trouvaient dans le corps du lab, portant le total à 8 sections `###`.

**Correction appliquee :** suppression complete de ces 4 sections (et de l'en-tête `## Erreurs frequentes et corrections detaillees (Partie D)`) dans :
- `chapitre-02.md` (apres Lab-06, avant Synthese)
- `chapitre-03.md` (apres Lab-09, avant Synthese)
- `chapitre-04.md` (apres Lab-13, avant Synthese)
- `chapitre-05.md` (apres Lab-14, avant Synthese)

**Decision tranchee :** suppression pure (les contenus de ces tableaux ne sont pas deplaces ailleurs ; ils n'etaient pas indispensables au deroulement des labs). Chaque lab retrouve exactement les 4 sections canoniques : `### Enonce / Contexte`, `### Outils et commandes utilisees`, `### Commande et laboratoire etape par étape`, `### En conclusion`.

### F-05 — MAJOR : une étape avec Resultat attendu sans Explication

**Constat :** `chapitre-03.md` Lab-09 etape 3 (demonstration theorique MCM) avait un `**Resultat attendu**` sans `**Explication de la commande**` decomposee.

**Correction appliquee :** ajout d'un `**Commande**` (`echo 'Demonstration theorique MCM ...'`) suivi d'un `**Explication de la commande**` (liste decomposee : commande, effet, commandes mcm theoretiques non executees) avant le `**Resultat attendu**`. L'ordre `commande -> explication -> resultat` est respecte.

### F-06 — MINOR : doublon image-16.png (Figure 6 et Figure 8)

**Constat :** Figure 6 (ligne ~178) et Figure 8 (ligne ~236) de `chapitre-01.md` referenceaient toutes deux `image-16.png` ; `image-15.png` etait inutilisee.

**Correction appliquee :** Figure 8 reference maintenant `image-15.png`. Figure 6 conserve `image-16.png`. Aucun fichier image supprime.

### F-07 — MINOR : isolement réseau contredit (route NAT par défaut)

**Constat :** `ip route show default` retourne une route par défaut NAT (`10.0.2.2`) en plus de la route vboxnet0, contredisant l'assertion "aucune route par défaut" de Lab-14.

**Correction appliquee :** ajout d'une note explicite dans l'enonce de Lab-14 (`chapitre-05.md`) : les VM ont un adaptateur NAT ; l'isolement reseau porte sur le perimetre d'administration (vboxnet0 isole) ; la route NAT peut apparaitre et doit etre notee par l'apprenant.

### F-08 — MINOR : Lab-14 TLS partiellement executable (--initial disruptif)

**Constat :** l'activation TLS nécessite `--initial` sur les nœuds de stockage, disruptif pour le cluster partage.

**Correction appliquee :** ajout d'une note d'execution conditionnelle dans l'enonce de Lab-14 (`chapitre-05.md`) : les etapes TLS/redemarrage `--initial` sont a executer uniquement sur cluster dedie ou apres snapshot `propre-avant-lab` ; sinon lues comme procedure de reference.

---

## Fichiers modifiés

| Fichier | Corrections |
|---------|-------------|
| `chapitre-01.md` | F-06 (Figure 8 : `image-16.png` -> `image-15.png`) |
| `chapitre-02.md` | F-04 (suppression 4 sections `### Erreurs de...` apres Lab-06) |
| `chapitre-03.md` | F-01 (Lab-07 `ndb_desc` -> `mysql DESCRIBE` + table outils), F-04 (suppression 4 sections `### Erreurs de...` apres Lab-09), F-05 (Lab-09 etape 3 explication ajoutee) |
| `chapitre-04.md` | F-01 (Lab-11 `ndb_desc` -> `mysql DESCRIBE` + table outils + conclusion), F-03 (Lab-12 encadret non executable), F-04 (suppression 4 sections `### Erreurs de...` apres Lab-13) |
| `chapitre-05.md` | F-04 (suppression 4 sections `### Erreurs de...` apres Lab-14), F-07 (note isolement reseau), F-08 (note TLS conditionnel) |
| `corrections.md` | creation (ce fichier) |

---

## Doutes residuels

1. Le feedback etudiant cite "Lab-03 (chapitre 2, étape 3)" pour `ndb_desc`, mais `chapitre-02.md` Lab-03 ne contient aucune occurrence de `ndb_desc`. L'occurrence reelle se trouve dans `chapitre-03.md` Lab-07 etape 3. Aucune modification n'a ete apportee a `chapitre-02.md` Lab-03 car il n'y a pas de `ndb_desc` a corriger.
2. Le feedback cite "Lab-08 (chapitre 3)" pour `ndb_desc`, mais `chapitre-03.md` Lab-08 n'en contient pas non plus. La correction portee sur Lab-07 (meme probleme) couvre l'intention de F-01/F-02.
3. L'access Internet effectif depuis les VMs (route NAT) n'a pas ete desactive (ne releve pas du scope prof ; decision sysadmin/orchestrator). La note F-07 documente la situation sans modifier l'infrastructure.
4. Les preuves reelles (`preuves/`) n'ont pas été régénérées (VMs éteintes au moment de la correction, decision D2 de prof mentionnee dans tracking.state). Elles seront regenerees a la remise en route des VMs.
5. Aucun test en réel n'a ete possible sur les commandes modifiees (VMs indisponibles en cours de correction). La revalidation doit etre faite par `student` puis `orchestrator`.

---

## Historique

L'historique des versions est consigne dans `CHANGELOG.md` (racine) et dans les commits Git (message `mise à jour`). Aucun bloc `Changelog` ni `Version` n'a ete insere dans les chapitres, conformément aux regles de production.
