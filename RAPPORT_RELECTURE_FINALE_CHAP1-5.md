# Rapport de relecture finale — Chapitres 1 à 5 (MySQL Cluster)

**Agent** : prof — parcours "MySQL Cluster — Administration et exploitation"
**Date** : 2026-11-22
**Fichiers relus et corrigés** : `chapitre-01.md`, `chapitre-02.md`, `chapitre-03.md`, `chapitre-04.md`, `chapitre-05.md`
**Contrainte respectée** : aucun commit, aucun push, aucun secret affiché, aucune réinstallation de VM.

---

## Méthode

Lecture intégrale des 5 chapitres selon 4 critères :
1. Syntaxe et français (orthographe, grammaire, ponctuation, accents, termes techniques).
2. Cohérence (IPs, noms de nœuds / NodeId, commandes, chemins de fichiers).
3. Erreurs et anomalies (commandes invalides/obsolètes, sections inexistantes, incohérence schéma/texte, blocs `Résultat attendu` vides ou absurdes, références `preuves/`, sections `Corrigé` / blocs `Changelog`).
4. Format canonique (titre `## Lab-XX`, exactement 4 sections `###`, ordre d'étape, encart de localisation).

Vérifications automatisées complémentaires par `grep` sur les 5 fichiers de chapitres.

---

## Synthèse globale

- 5 chapitres, 10 labs (Lab-01 à Lab-12).
- Toutes les corrections ont été appliquées **directement dans les fichiers** (pas de corrigé séparé, pas de bloc `Changelog` dans les chapitres).
- **Zéro référence `preuves/` dans le corps des chapitres** (confirmé par grep).
- **Zéro occurrence du mot "port" / "portuaire" dans la partie cours/vocabulaire** (la phrase-contrainte a été réécrite pour ne plus les citer).
- Format canonique respecté sur **tous les labs**.
- Alignement syllabus maintenu pour NDB-01 à NDB-25 et NDB-29 à NDB-31 ; écart identifié pour NDB-26/27/28 (module 4.1, voir ci-dessous).

---

## Chapitre par chapitre — corrections apportées

### Chapitre 1 — Introduction et installation de MySQL Cluster (Lab-01, Lab-02)

#### Syntaxe et français
| Ref | Emplacement (ligne approx.) | Correction |
|---|---|---|
| C1.1 | L16 (avertissement) | Phrase-contrainte réécrite : suppression des mots interdits « port » / « portuaire ». Désormais : « la désignation textuelle des canaux de communication n'est pas employée… ». |
| C1.2 | L130 | « définir explícitement » → « définir explicitement » (accent manquant sur le premier e). |
| C1.3 | L234/273, 301/323, 340/371, 399/417, 434/464, 492/510, 1010/1022 | Accents rétablis dans les chaînes `echo` et les blocs `Résultat attendu` : « nettoyage VM X terminé », « config VM X terminé », « démarrage des nœuds SQL terminé ». |
| C1.4 | L~930 (Lab-02 étape 6 explication) | « nœuds de données » → « nœuds de stockage » (cohérence avec le vocabulaire du cours). |

#### Cohérence
- Adresses IP identiques partout : `192.168.56.10` (gestion-sql), `192.168.56.11` (stockage), `192.168.56.12` (mysql-node3), hôte `192.168.56.1`.
- NodeId cohérents : `ndb_mgmd` Id=1, `ndbmtd` Id=2 et Id=3, `mysqld` Id=4 (VM1) et Id=5 (VM3).
- Chemins cohérents : `/var/lib/mysql-cluster`, `/etc/netplan/01-netcfg.yaml`, `/var/lib/mysql-cluster/config.ini`.
- Le `config.ini` est identique entre la référence (L92-126), Lab-02 étape 5 et Lab-05 étape 1.

#### Erreurs et anomalies (corrigées)
| Ref | Anomalie | Correction |
|---|---|---|
| E1.1 (bloquant) | **Lab-02 ne contenait aucune étape d'installation des paquets.** L'énoncé promet « Installer les composants MySQL Cluster », mais après la vérification (« aucun paquet ndb »), le lab enchaînait directement sur `config.ini` puis le démarrage de `ndb_mgmd`/`ndbmtd`/`mysqld` qui n'existeraient pas sur des VM fraîches. | Ajout d'une nouvelle **Étape 4 — Installer les paquets MySQL Cluster sur les 3 VM** (`apt-get update && apt-get install -y …`, paquets adaptés par VM : gestion+SQL sur VM1, data-node sur VM2, SQL sur VM3). Anciennes étapes 4→11 renumérotées en 5→12. Références croisées mises à jour (prérequis étape 11 = « Étape 10 réussie » ; référence proposition « étape 12 du Lab-02 »). Ajout d'une ligne `apt-get` dans la table « Outils et commandes utilisées ». |
| E1.2 | Chaînes `echo` sans accents (ortographe dans les sorties d'exemple). | Voir C1.3. |

#### Format canonique
- `## Lab-01 — Mise en place manuelle des 3 VM` et `## Lab-02 — Installation de MySQL Cluster sur les 3 VM` (jamais `## 6. Lab-01`).
- Exactement 4 sections `###` par lab : Énoncé / Contexte, Outils et commandes utilisées, Commande et laboratoire étape par étape, En conclusion.
- Ordre d'étape respecté : `**But**` → `**Machine**` → `**Prérequis**` → encart de localisation → commande → explication en liste → `**Résultat attendu**`.
- Les sous-blocs « Suite — Redémarrage… » et « Vérification finale de la réintégration » de l'étape 12 conservent leur encart de localisation (patron déjà utilisé à l'étape 8 de Lab-01).

---

### Chapitre 2 — Architecture et Administration de MySQL Cluster (Lab-03 à Lab-06)

#### Syntaxe et français
| Ref | Emplacement | Correction |
|---|---|---|
| C2.1 | L16 (avertissement) | Phrase-contrainte réécrite (suppression « port » / « portuaire »). |
| C2.2 | L818 | « un node déclare un autre mort » → « un nœud déclare un autre mort » (terme « nœud »). |

#### Erreurs et anomalies (corrigées)
| Ref | Anomalie | Correction |
|---|---|---|
| E2.1 | Lab-06 étape 1 (L~690) : `echo 'T0=$(date +%s)'` entre **simples quotes** empêchait la substitution de commande (la sortie réelle aurait été le texte littéral `T0=$(date +%s)`, incohérent avec le résultat attendu `T0=1763800000`). | Remplacé par `echo "T0=$(date +%s)"` (id. pour `T1`). La substitution de commande fonctionne désormais. |

#### Cohérence
- IPs, NodeId, chemins vérifiés et identiques entre énoncé, étapes et schémas Mermaid (Fig 2.1, 2.2, 2.3 cohérents avec le texte).

---

### Chapitre 3 — Supervision et Maintenance de MySQL Cluster (Lab-07 à Lab-09)

#### Syntaxe et français
| Ref | Emplacement | Correction |
|---|---|---|
| C3.1 | L16 (avertissement) | Phrase-contrainte réécrite (suppression « port » / « portuaire »). |
| C3.2 | Lab-08 étape 2 (L~312) | Chaîne `echo` corrigée : « répertoire BACKUP non trouvé sur ce système » (accents). |
| C3.3 | Lab-09 étape 1 (L~533) + résultat attendu (L~546) | « paquet mcm non installe » → « paquet mcm non installé ». |

#### Cohérence
- IPs, NodeId, chemins cohérents. Schémas Fig 3.1 et 3.2 cohérents avec le texte.

---

### Chapitre 4 — Optimisation des Performances et Scalabilité (Lab-10, Lab-11)

#### Syntaxe et français
| Ref | Emplacement | Correction |
|---|---|---|
| C4.1 | L16 (avertissement) | Phrase-contrainte réécrite (suppression « port » / « portuaire »). |

#### Erreurs et anomalies (corrigées)
| Ref | Anomalie | Correction |
|---|---|---|
| E4.1 | Fig 4.2 (L~70-77) : **incohérence schéma/texte** — NodeId 4 et NodeId 5 (nœuds SQL `mysqld`) étaient utilisés comme réplicas de stockage dans le diagramme de montée en charge. | Remplacés par **NodeId 6 et NodeId 7** (nœuds de stockage), cohérents avec le texte et avec la préparation des répertoires `ndb_7`/`ndb_8` à l'étape 4 du Lab-11. |
| E4.2 | Lab-11 étape 1 (L~326) : **commande `mysql` invalide** — guillettes déséquilibrées (`' … ' 2>&1"`) et séquence `\a\"` invalide à l'intérieur d'une chaîne simple-quotée. | Réécriture complète de la commande avec guillemets doubles et valeurs SQL `'a'`…`'e'` : `mysql -u root -e "CREATE DATABASE … ; INSERT … VALUES (1,'a'),(2,'b'),(3,'c'),(4,'d'),(5,'e') … ; SELECT COUNT(*) … ;"`. |

#### Cohérence
- IPs, NodeId, chemins cohérents. Schémas Fig 4.1 et 4.2 (corrigé) cohérents avec le texte.

---

### Chapitre 5 — Sécuriser MySQL Cluster (Lab-12)

#### Syntaxe et français
| Ref | Emplacement | Correction |
|---|---|---|
| C5.1 | L16 (avertissement) | Phrase-contrainte réécrite (suppression « port » / « portuaire »). |

#### Dé-cyberisation (vérifiée)
- Chapitre 5 bien dé-cyberisé : seules les opérations **NDB-29 (sécurité connexions), NDB-30 (sécurité données), NDB-31 (sécurité nœuds serveurs)** du syllabus sont abordées.
- Aucun contenu de type pentest, red team, SOC, SIEM, CVE, exploit, malware, IDS/IPS ou pare-feu complexe (avertissement L14 et conclusion L~627 le réaffirment).
- Chiffrement TLS inter-nœuds via `config.ini` (`TLS = 1`, `TLSCAFile`, `TLSCertificateFile`, `TLSKeyFile`), comptes SQL à moindre privilège, sauvegardes protégées (`chmod 700`), isolement réseau (pas de route par défaut vers Internet). Aucun changement structurel nécessaire.

---

## Confirmations

1. **Zéro référence `preuves/` dans le corps des chapitres** : confirmé par `grep` sur `chapitre-0*.md`. Le mot « preuves » n'apparaît que dans l'avertissement (« …stockage des preuves »), qui n'est pas un chemin de répertoire `preuves/`. (Les références à `preuves/` ne subsistent que dans le fichier d'auto-test `chapitre-01-self-test.md`, qui n'est pas un chapitre.)
2. **Zéro section `Corrigé` séparée et zéro bloc `Changelog` dans les chapitres** : confirmé par `grep`. La solution reste intégrée au déroulement de chaque lab.
3. **Format canonique respecté sur tous les labs** : 10 labs, tous intitulés `## Lab-XX — Titre`, chacun avec exactement 4 sections `###` dans l'ordre prescrit, et chaque étape suivant `But → Machine → Prérequis → encart de localisation → commande → explication en liste → Résultat attendu`.
4. **Pas de mot « port » ni « portuaire » dans la partie cours/vocabulaire** (la phrase-contrainte a été réécrite pour ne plus les mentionner).

---

## Alignement syllabus (NDB-01 à NDB-31)

| Opérations de référence | Couverture dans les chapitres |
|---|---|
| NDB-01, NDB-02 | Chapitre 1 (module 1.0) |
| NDB-03, NDB-04, NDB-05, NDB-08 | Chapitre 1 (module 1.1, Lab-02) |
| NDB-06 à NDB-15 | Chapitre 2 (Lab-03 à Lab-06) |
| NDB-16 à NDB-22 | Chapitre 3 (Lab-07 à Lab-09) |
| NDB-23, NDB-24, NDB-25 | Chapitre 4 (Lab-10, Lab-11) |
| NDB-29, NDB-30, NDB-31 | Chapitre 5 (Lab-12) |

**Écart identifié** : **NDB-26 (réplication inter-clusters), NDB-27 (gestion des pannes), NDB-28 (failover/failback)** — module 4.1 du syllabus (Jour 4) — ne sont abordés dans **aucun** des chapitres 1 à 5. Ce n'est pas une erreur de rédaction des chapitres existants, mais une couverture incomplète du référentiel syllabus à ce stade du parcours.

---

## Recommandation : les chapitres sont-ils prêts pour le test réel des labs ?

**Oui, sous réserve des points suivants :**

1. **Exécution réelle de Lab-01 et Lab-02 sur les 3 VM** (conformément à `tracking.state`) : remplacer les blocs `**Résultat attendu**` par des sorties réelles capturées et générer les preuves dans `preuves/ch1-lab1/` et `preuves/ch1-lab2/` (en-têtes `# date:`, `# cmd:`, `# rc:`).
2. **Disponibilité des paquets** : l'étape d'installation ajoutée (Lab-02 étape 4) nécessite un accès temporaire au dépôt MySQL (adaptateur NAT) ou un cache apt local sur chaque VM.
3. **Écart NDB-26/27/28** : décision pédagogique à prendre (ajout d'un module 4.1 ou documentation de l'écart comme hors périmètre de ce parcours) avant validation finale.
4. Une fois le cluster du chapitre 1 validé, les chapitres 2 à 5 peuvent faire l'objet d'auto-tests ciblés sur le cluster déjà déployé.

---
*Rapport généré par l'agent `prof`. Aucun fichier n'a été commité ni poussé.*