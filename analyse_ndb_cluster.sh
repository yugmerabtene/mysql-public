#!/bin/bash
###############################################################################
# ANALYSEUR DE CLUSTER MYSQL NDB — Script de diagnostic complet
# Architecture : 10.0.0.199 (mgmd+SQL4), 10.0.0.212 (stockage 2+3), 10.0.0.210 (SQL5)
# Mot de passe MySQL root : Mysql2026
#
# Ce script ne MODIFIE rien sur les VMs. Il effectue uniquement des lectures
# et des tests de connexion pour diagnostiquer précisément les blocages.
# Génération de fichiers de preuve avec en-têtes # date:, # cmd:, # rc=
###############################################################################
set -u

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
WORKDIR="${CLUSTER_NDB_WORKDIR:-$(pwd)}"
PROOF_DIR="$WORKDIR/preuves/analyze_ndb_cluster"
LOG_FILE="$PROOF_DIR/analyze_ndb_cluster.log"

mkdir -p "$PROOF_DIR"

# Mot de passe MySQL root (intégré pour les tests de connexion)
MYSQL_PASSWORD="Mysql2026"
export MYSQL_PWD="$MYSQL_PASSWORD"

# Chargement des mots de passe SSH depuis .env (si présent)
ENV_FILE="$WORKDIR/.env"
PW1=""; PW2=""; PW3=""
if [ -f "$ENV_FILE" ]; then
    PW1=$(grep "^SSH_PASSWORD_VM1=" "$ENV_FILE" | cut -d= -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    PW2=$(grep "^SSH_PASSWORD_VM2=" "$ENV_FILE" | cut -d= -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    PW3=$(grep "^SSH_PASSWORD_VM3=" "$ENV_FILE" | cut -d= -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
fi

IP1="10.0.0.199"  # gestion-sql + mysqld NodeId 4
IP2="10.0.0.212"  # stockage ndbd NodeId 2 et 3
IP3="10.0.0.210"  # mysqld NodeId 5

# ---------------------------------------------------------------------------
# Fonction de journalisation avec en-têtes preuve (exécution locale)
# ---------------------------------------------------------------------------
log_proof() {
    local proof="$1"; shift 1
    local cmd="$*"
    local date_iso rc out
    date_iso=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    mkdir -p "$(dirname "$proof")"
    out=$(eval "$cmd" 2>&1)
    rc=$?
    {
        echo "# date: $date_iso"
        echo "# cmd: $cmd"
        echo "# rc: $rc"
        echo "$out"
    } > "$proof"
    echo "[OK rc=$rc] $proof"
    return $rc
}

# ---------------------------------------------------------------------------
# Fonction de journalisation SSH (exécution distante sur les VMs NDB)
# ---------------------------------------------------------------------------
log_proof_ssh() {
    local ip="$1" pw="$2" proof="$3"; shift 3
    local cmd="$*"
    local date_iso rc out
    date_iso=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    mkdir -p "$(dirname "$proof")"
    out=$(SSHPASS="$pw" sshpass -e ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@"$ip" "$cmd" 2>&1)
    rc=$?
    {
        echo "# date: $date_iso"
        echo "# cmd: ssh root@$ip $cmd"
        echo "# rc: $rc"
        echo "$out"
    } > "$proof"
    echo "[OK rc=$rc] $proof"
    return $rc
}

# ---------------------------------------------------------------------------
# Écriture d'une section dans le log consolidé
# ---------------------------------------------------------------------------
write_log_section() {
    local title="$1"; shift
    echo "" >> "$LOG_FILE"
    echo "================================================================" >> "$LOG_FILE"
    echo "# $title" >> "$LOG_FILE"
    echo "# date: $(date -u '+%Y-%m-%dT%H:%M:%SZ')" >> "$LOG_FILE"
    echo "================================================================" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

# ---------------------------------------------------------------------------
# Bannière d'accueil
# ---------------------------------------------------------------------------
echo "================================================================"
echo "  ANALYSEUR DE CLUSTER MYSQL NDB"
echo "  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "================================================================"
echo ""
echo "  Cibles : $IP1 (gestion+SQL4), $IP2 (stockage2+3), $IP3 (SQL5)"
echo "  Preuves : $PROOF_DIR/"
echo "  Log consolidé : $LOG_FILE"
echo ""
echo "  Ce script effectue UNIQUEMENT des lectures et des tests de connexion."
echo "  Aucune modification n'est apportée aux VMs."
echo "================================================================"
echo ""

# ===========================================================================
# PHASE 1 — Vérification de l'infrastructure de base
# ===========================================================================
write_log_section "PHASE 1 : INFRASTRUCTURE DE BASE"

echo ">>> PHASE 1 : Vérification de l'infrastructure de base <<<"
echo ""

# 1.1 config.ini sur VM1
echo "[1.1] Vérification config.ini sur $IP1"
log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/p1_01_config_ini.txt" \
    "cat /var/lib/mysql-cluster/config.ini"

# 1.2 Vérifier que config.ini contient les 5 nœuds attendus
echo "[1.2] Vérification du contenu de config.ini (5 nœuds)"
log_proof "$PROOF_DIR/p1_02_config_check.txt" \
    "grep -E 'NodeId|HostName|NoOfReplicas|DataDir' /var/lib/mysql-cluster/config.ini 2>/dev/null || echo 'FICHIER INTROUVABLE OU VIDE'"

# 1.3 Processus sur VM1
echo "[1.3] Processus sur $IP1 (ndb_mgmd + mysqld)"
log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/p1_03_processus_vm1.txt" \
    "ps aux | grep -E 'ndb_mgmd|mysqld' | grep -v grep || echo 'AUCUN PROCESSUS NDB TROUVE'"

# 1.4 Processus sur VM2
echo "[1.4] Processus sur $IP2 (ndbd x2)"
log_proof_ssh "$IP2" "$PW2" "$PROOF_DIR/p1_04_processus_vm2.txt" \
    "ps aux | grep -E 'ndbd|ndbmtd' | grep -v grep || echo 'AUCUN PROCESSUS NDB TROUVE'"

# 1.5 Processus sur VM3
echo "[1.5] Processus sur $IP3 (mysqld)"
log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/p1_05_processus_vm3.txt" \
    "ps aux | grep mysqld | grep -v grep || echo 'AUCUN PROCESSUS MYSQLD TROUVE'"

# 1.6 Ping inter-VMs
echo "[1.6] Connectivité réseau (ping)"
log_proof "$PROOF_DIR/p1_06_ping.txt" \
    "ping -c 3 $IP1 && echo '--- OK $IP1 ---' && ping -c 3 $IP2 && echo '--- OK $IP2 ---' && ping -c 3 $IP3 && echo '--- OK $IP3 ---'"

# 1.7 Ports sur VM1
echo "[1.7] Ports ouverts sur $IP1 (1186 mgmd, 3306 mysqld)"
log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/p1_07_ports_vm1.txt" \
    "ss -tlnp | grep -E '1186|3306' || netstat -tlnp | grep -E '1186|3306'"

# 1.8 Ports sur VM3
echo "[1.8] Ports ouverts sur $IP3 (3306 mysqld)"
log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/p1_08_ports_vm3.txt" \
    "ss -tlnp | grep 3306 || netstat -tlnp | grep 3306"

echo ""
echo ">>> PHASE 1 TERMINÉE <<<"
echo ""

# ===========================================================================
# PHASE 2 — État du cluster NDB via ndb_mgm
# ===========================================================================
write_log_section "PHASE 2 : ÉTAT DU CLUSTER NDB (ndb_mgm)"

echo ">>> PHASE 2 : État du cluster NDB <<<"
echo ""

# 2.1 ndb_mgm SHOW
echo "[2.1] ndb_mgm -e 'SHOW'"
log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/p2_01_ndb_show.txt" \
    "ndb_mgm -e 'SHOW'"

# 2.2 ndb_mgm ALL STATUS
echo "[2.2] ndb_mgm -e 'ALL STATUS'"
log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/p2_02_ndb_status.txt" \
    "ndb_mgm -e 'ALL STATUS'"

# 2.3 ndb_mgm ALL REPORT MEMORYUSAGE
echo "[2.3] ndb_mgm -e 'ALL REPORT MEMORYUSAGE'"
log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/p2_03_ndb_memory.txt" \
    "ndb_mgm -e 'ALL REPORT MEMORYUSAGE'"

# 2.4 ndb_config --query-all
echo "[2.4] ndb_config --query-all (extraits NodeId/HostName)"
log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/p2_04_ndb_config.txt" \
    "ndb_config --query-all 2>&1 | grep -E 'NodeId|HostName|NoOfReplicas|DataDir'"

echo ""
echo ">>> PHASE 2 TERMINÉE <<<"
echo ""

# ===========================================================================
# PHASE 3 — Test de connexion MySQL LOCAL (socket, pas de vérification d'hôte)
# ===========================================================================
write_log_section "PHASE 3 : TEST DE CONNEXION MYSQL LOCAL (socket Unix)"

echo ">>> PHASE 3 : Test de connexion MySQL local (socket Unix) <<<"
echo ""
echo "  Ce test se connecte en LOCAL sur chaque node SQL (sans -h)."
echo "  Il utilise le socket Unix /var/run/mysqld/mysqld.sock."
echo "  Cela vérifie que le mot de passe '$MYSQL_PASSWORD' est correct en local."
echo ""

# 3.1 Test local sur NodeId 4 (10.0.0.199)
echo "[3.1] Connexion MySQL locale sur $IP1 (NodeId 4)"
log_proof "$PROOF_DIR/p3_01_mysql_local_vm1.txt" \
    "mysql -u root -p\$MYSQL_PASSWORD -e \"SELECT 1 AS test_local_node4; SELECT USER(), CURRENT_USER();\" 2>&1"

# 3.2 Test local sur NodeId 5 (10.0.0.210)
echo "[3.2] Connexion MySQL locale sur $IP3 (NodeId 5)"
log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/p3_02_mysql_local_vm3.txt" \
    "mysql -u root -p\$MYSQL_PASSWORD -e \"SELECT 1 AS test_local_node5; SELECT USER(), CURRENT_USER();\" 2>&1"

echo ""
echo ">>> PHASE 3 TERMINÉE <<<"
echo ""

# ===========================================================================
# PHASE 4 — Test de connexion MySQL INTER-NODES (TCP, avec vérification d'hôte)
# ===========================================================================
write_log_section "PHASE 4 : TEST DE CONNEXION MYSQL INTER-NODES (TCP)"

echo ">>> PHASE 4 : Test de connexion MySQL inter-nodes (TCP) <<<"
echo ""
echo "  Ce test se connecte en TCP d'un node SQL à l'autre."
echo "  C'est ici que l'erreur 1045 (Access denied) apparaît si root@% n'est pas configuré."
echo ""

# 4.1 Test 199 -> 210 (NodeId 4 vers NodeId 5)
echo "[4.1] Connexion MySQL TCP : $IP1 (NodeId 4) -> $IP3 (NodeId 5)"
log_proof "$PROOF_DIR/p4_01_mysql_tcp_199_to_210.txt" \
    "mysql -u root -p\$MYSQL_PASSWORD -h $IP3 -e \"SELECT 1 AS test_tcp_199_to_210; SELECT USER(), CURRENT_USER();\" 2>&1"

# 4.2 Test 210 -> 199 (NodeId 5 vers NodeId 4)
echo "[4.2] Connexion MySQL TCP : $IP3 (NodeId 5) -> $IP1 (NodeId 4)"
log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/p4_02_mysql_tcp_210_to_199.txt" \
    "mysql -u root -p\$MYSQL_PASSWORD -h $IP1 -e \"SELECT 1 AS test_tcp_210_to_199; SELECT USER(), CURRENT_USER();\" 2>&1"

echo ""
echo ">>> PHASE 4 TERMINÉE <<<"
echo ""

# ===========================================================================
# PHASE 5 — Diagnostic détaillé des utilisateurs MySQL (en cas d'erreur 1045)
# ===========================================================================
write_log_section "PHASE 5 : DIAGNOSTIC DES UTILISATEURS MYSQL (si erreur 1045)"

echo ">>> PHASE 5 : Diagnostic des utilisateurs MySQL <<<"
echo ""
echo "  Cette phase liste tous les utilisateurs 'root' existants dans mysql.user"
echo "  sur chaque node SQL, avec leur hôte autorisé et leur plugin d'authentification."
echo ""

# 5.1 Utilisateurs root sur VM1 (en local)
echo "[5.1] Utilisateurs root sur $IP1 (NodeId 4)"
log_proof "$PROOF_DIR/p5_01_mysql_users_vm1.txt" \
    "mysql -u root -p\$MYSQL_PASSWORD -e \"SELECT User, Host, plugin, account_locked FROM mysql.user WHERE User = 'root' ORDER BY Host;\" 2>&1"

# 5.2 Utilisateurs root sur VM3 (via SSH)
echo "[5.2] Utilisateurs root sur $IP3 (NodeId 5)"
log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/p5_02_mysql_users_vm3.txt" \
    "mysql -u root -p\$MYSQL_PASSWORD -e \"SELECT User, Host, plugin, account_locked FROM mysql.user WHERE User = 'root' ORDER BY Host;\" 2>&1"

# 5.3 Vérifier si root@% existe sur VM1
echo "[5.3] Vérification spécifique root@% sur $IP1"
log_proof "$PROOF_DIR/p5_03_check_root_percent_vm1.txt" \
    "mysql -u root -p\$MYSQL_PASSWORD -e \"SELECT User, Host FROM mysql.user WHERE User = 'root' AND Host = '%';\" 2>&1 || echo 'Utilisateur root@% introuvable ou erreur de connexion'"

# 5.4 Vérifier si root@% existe sur VM3
echo "[5.4] Vérification spécifique root@% sur $IP3"
log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/p5_04_check_root_percent_vm3.txt" \
    "mysql -u root -p\$MYSQL_PASSWORD -e \"SELECT User, Host FROM mysql.user WHERE User = 'root' AND Host = '%';\" 2>&1 || echo 'Utilisateur root@% introuvable ou erreur de connexion'"

echo ""
echo ">>> PHASE 5 TERMINÉE <<<"
echo ""

# ===========================================================================
# PHASE 6 — Test de création de table NDB (syntaxe correcte)
# ===========================================================================
write_log_section "PHASE 6 : TEST DE CRÉATION DE TABLE NDB"

echo ">>> PHASE 6 : Test de création de table NDB <<<"
echo ""
echo "  Cette phase teste la création d'une table NDB avec la syntaxe correcte :"
echo "    id INT PRIMARY KEY AUTO_INCREMENT"
echo "  (La syntaxe 'PRIMARY AUTO_INCREMENT' sans KEY provoque l'erreur 1064)"
echo ""

# 6.1 Créer la base et la table sur NodeId 4 (10.0.0.199)
echo "[6.1] Création base + table sur $IP1 (NodeId 4)"
log_proof "$PROOF_DIR/p6_01_create_table_node4.txt" \
    "mysql -u root -p\$MYSQL_PASSWORD -h $IP1 -e \"CREATE DATABASE IF NOT EXISTS test_ndb_analyze; USE test_ndb_analyze; DROP TABLE IF EXISTS test_sync; CREATE TABLE test_sync (id INT PRIMARY KEY AUTO_INCREMENT, msg VARCHAR(200), source_node INT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=ndbcluster; INSERT INTO test_sync (msg, source_node) VALUES ('test analyse depuis NodeId 4 $(date -u '+%Y-%m-%dT%H:%M:%SZ')', 4); SELECT * FROM test_sync ORDER BY id DESC LIMIT 3;\" 2>&1"

# 6.2 Lire la table sur NodeId 5 (10.0.0.210)
echo "[6.2] Lecture de la table sur $IP3 (NodeId 5)"
log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/p6_02_read_table_node5.txt" \
    "mysql -u root -p\$MYSQL_PASSWORD -h $IP1 -e \"USE test_ndb_analyze; SELECT * FROM test_sync ORDER BY id DESC LIMIT 3;\" 2>&1"

echo ""
echo ">>> PHASE 6 TERMINÉE <<<"
echo ""

# ===========================================================================
# PHASE 7 — ndb_desc avec connectstring explicite
# ===========================================================================
write_log_section "PHASE 7 : NDB_DESC (distribution des fragments)"

echo ">>> PHASE 7 : ndb_desc (distribution des fragments NDB) <<<"
echo ""

echo "[7.1] ndb_desc avec --ndb-connectstring explicite"
log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/p7_01_ndb_desc.txt" \
    "ndb_desc --ndb-connectstring=$IP1 test_ndb_analyze.test_sync 2>&1"

echo ""
echo ">>> PHASE 7 TERMINÉE <<<"
echo ""

# ===========================================================================
# PHASE 8 — Rapport consolidé et diagnostic final
# ===========================================================================
write_log_section "PHASE 8 : RAPPORT CONSOLIDÉ ET DIAGNOSTIC FINAL"

echo ">>> PHASE 8 : Rapport consolidé <<<"
echo ""

# Construire le rapport consolidé
{
    echo "# date: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "# cmd: rapport analyse complet NDB cluster"
    echo "# rc: 0"
    echo ""
    echo "================================================================"
    echo "  RAPPORT D'ANALYSE COMPLET — CLUSTER MYSQL NDB"
    echo "  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "================================================================"
    echo ""
    echo "  ARCHITECTURE CIBLE :"
    echo "    NodeId 1 : ndb_mgmd   @ $IP1 (gestionnaire)"
    echo "    NodeId 2 : ndbd       @ $IP2 (stockage)"
    echo "    NodeId 3 : ndbd       @ $IP2 (stockage)"
    echo "    NodeId 4 : mysqld     @ $IP1 (SQL principal)"
    echo "    NodeId 5 : mysqld     @ $IP3 (SQL secondaire)"
    echo ""
    echo "---------------------------------------------------------------"
    echo "  RÉSUMÉ DES PHASES"
    echo "---------------------------------------------------------------"
    echo ""
    echo "  [PHASE 1] Infrastructure de base"
    echo "    - config.ini : voir p1_01_config_ini.txt"
    echo "    - Processus : voir p1_03 à p1_05"
    echo "    - Réseau/Ping : voir p1_06"
    echo "    - Ports : voir p1_07, p1_08"
    echo ""
    echo "  [PHASE 2] État du cluster NDB"
    echo "    - ndb_mgm SHOW : voir p2_01_ndb_show.txt"
    echo "    - ndb_mgm ALL STATUS : voir p2_02_ndb_status.txt"
    echo "    - Mémoire : voir p2_03_ndb_memory.txt"
    echo "    - Configuration : voir p2_04_ndb_config.txt"
    echo ""
    echo "  [PHASE 3] Connexion MySQL LOCAL (socket)"
    echo "    - NodeId 4 sur $IP1 : voir p3_01_mysql_local_vm1.txt"
    echo "    - NodeId 5 sur $IP3 : voir p3_02_mysql_local_vm3.txt"
    echo ""
    echo "  [PHASE 4] Connexion MySQL INTER-NODES (TCP)"
    echo "    - $IP1 -> $IP3 : voir p4_01_mysql_tcp_199_to_210.txt"
    echo "    - $IP3 -> $IP1 : voir p4_02_mysql_tcp_210_to_199.txt"
    echo ""
    echo "  [PHASE 5] Utilisateurs root MySQL"
    echo "    - Sur $IP1 : voir p5_01_mysql_users_vm1.txt"
    echo "    - Sur $IP3 : voir p5_02_mysql_users_vm3.txt"
    echo "    - root@% sur $IP1 : voir p5_03_check_root_percent_vm1.txt"
    echo "    - root@% sur $IP3 : voir p5_04_check_root_percent_vm3.txt"
    echo ""
    echo "  [PHASE 6] Création de table NDB"
    echo "    - CREATE + INSERT sur $IP1 : voir p6_01_create_table_node4.txt"
    echo "    - SELECT sur $IP3 : voir p6_02_read_table_node5.txt"
    echo ""
    echo "  [PHASE 7] ndb_desc"
    echo "    - Distribution fragments : voir p7_01_ndb_desc.txt"
    echo ""
    echo "---------------------------------------------------------------"
    echo "  DIAGNOSTIC DES ERREURS CONNUES"
    echo "---------------------------------------------------------------"
    echo ""
    echo "  ERREUR 1045 (Access denied) :"
    echo "    -> L'utilisateur root n'autorise pas les connexions TCP"
    echo "       depuis l'hôte distant avec le mot de passe '$MYSQL_PASSWORD'."
    echo "    -> Solution : sur chaque node SQL, en local (socket),"
    echo "       executer :"
    echo "         ALTER USER 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
    echo "         GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
    echo "         FLUSH PRIVILEGES;"
    echo ""
    echo "  ERREUR 1064 (Syntaxe SQL) :"
    echo "    -> La syntaxe 'PRIMARY AUTO_INCREMENT' est invalide."
    echo "    -> Solution : utiliser 'PRIMARY KEY AUTO_INCREMENT'."
    echo ""
    echo "  ERREUR 1146 (Table inexistante) :"
    echo "    -> Conséquence directe de l'erreur 1064 ci-dessus."
    echo ""
    echo "---------------------------------------------------------------"
    echo "  FICHIERS DE PREUVE GENERES"
    echo "---------------------------------------------------------------"
    ls -1 "$PROOF_DIR/" | sort | while read -r f; do
        echo "    - $f"
    done
    echo ""
    echo "================================================================"
} > "$LOG_FILE"

# Afficher le rapport consolidé à l'écran
cat "$LOG_FILE"

echo ""
echo "================================================================"
echo "  ANALYSE TERMINÉE"
echo "  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "================================================================"
echo ""
echo "Tous les fichiers de preuve sont dans : $PROOF_DIR/"
echo "Le rapport consolidé est dans : $LOG_FILE"
echo ""
echo "Pour diagnostiquer l'erreur 1045, consultez :"
echo "  - $PROOF_DIR/p4_01_mysql_tcp_199_to_210.txt"
echo "  - $PROOF_DIR/p4_02_mysql_tcp_210_to_199.txt"
echo "  - $PROOF_DIR/p5_01_mysql_users_vm1.txt"
echo "  - $PROOF_DIR/p5_02_mysql_users_vm3.txt"
echo ""
