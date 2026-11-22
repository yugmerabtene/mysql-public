# CHANGELOG — Parcours MySQL Cluster : Administration et exploitation

Historique centralisé des modifications du parcours. Aucun historique de version ne figure dans les chapitres (règle du format canonique).

---

## 2026-11-23 — Correction relecture intégrale `student` (5 chapitres)

Correction de l'ensemble du cours (`chapitre-01.md` → `chapitre-05.md`) à partir du relevé d'erreurs produit par l'agent `student` (posture débutant).

**Blokers corrigés (4, Lab-13 ch4) :**
- Refonte du Lab-13 « réplication inter-clusters » en lab de référence/démonstration (Lab-12) : config.ini Cluster B, port MGM 1188 cohérent, 2 nœuds de stockage (`NoOfReplicas = 2`), démarrage du nœud SQL replica Id=6 (port 3307). Sorties marquées « illustrative (non exécutée en lab) ».

**Majors corrigés :**
- NodeId/VM : `syllabus.md` + `AGENTS.md` alignés sur 3 VMs (gestion=1, stockage=2/3, SQL=4/5).
- Numérotation des labs réordonnée : Lab-01 → Lab-14 (réplication=Lab-12, failover=Lab-13, sécurité=Lab-14).
- `DataMemory`/`IndexMemory` uniformisés sur 256M/128M (résidus 512M/256M corrigés), exception documentée du Lab-10 (ch4).
- `2 STOP` homogénéisé (« Node 2: Node shutdown initiated ») ; `2 START` remplacé par la relance manuelle `ndbmtd`.
- Netplan : suppression `gateway4` (déprécié) et DNS `8.8.8.8` ; cohérence « aucune route par défaut ».
- ch5 : sections TLS `default` + certificats distincts, arrêt du cluster avant `--initial`, `START BACKUP` réintégré dans une étape dédiée, numérotation fantôme résolue, PIDs inventés supprimés.
- ch3 Lab-08 : numérotation corrigée, résultat NodeId 6 rempli, `ndb_desc` précédé d'une création de table, Lab-09 `dpkg -l` honnête.
- ch2 Lab-05 : étape de suppression ajoutée, NodeId 6 abouti dans `SHOW`.
- ch1 : cartographie NDB-08 (un seul node group), `dpkg -l` par VM, restructuration Étape 12/13.
- ch4 Lab-10/11 : résultats vides remplis, avertissement interruption de service (`--initial`), note dépréciation `IndexMemory`.

**Preuves :** sorties réelles conservées ; sorties non exécutées marquées « illustrative ». Régénération des fichiers `preuves/` à prévoir à la remise en route des VMs (aucune VM réinstallée/reconfigurée).

Voir `RAPPORT_CORRECTIONS_RELECTURE_STUDENT.md` pour le détail.

---

## Historique antérieur

Les versions antérieures sont consignées dans les commits Git (messages `mise à jour`) et les tags/releases du dépôt. Ce fichier devient le point d'entrée de l'historique à compter de la présente date.
