#!/bin/bash
###############################################################################
# GESTIONNAIRE DE CLUSTER MYSQL NDB — Menu interactif (version améliorée v3)
# Architecture : 10.0.0.199 (mgmd+SQL4), 10.0.0.212 (stockage 2+3), 10.0.0.210 (SQL5)
# Mot de passe MySQL root : Mysql2026 (intégré via MYSQL_PWD)
# Génération de preuves avec en-têtes # date:, # cmd:, # rc=
###############################################################################
set -u

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
WORKDIR="${CLUSTER_NDB_WORKDIR:-$(pwd)}"
PROOF_DIR="$WORKDIR/preuves/cluster_manager"
LOG_FILE="$PROOF_DIR/cluster_manager.log"

mkdir -p "$PROOF_DIR"

# Mot de passe MySQL root (intégré comme demandé)
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

IP1="${CLUSTER_NDB_IP1:-10.0.0.199}"  # gestion-sql + mysqld NodeId 4
IP2="${CLUSTER_NDB_IP2:-10.0.0.212}"  # stockage ndbd NodeId 2 et 3
IP3="${CLUSTER_NDB_IP3:-10.0.0.210}"  # mysqld NodeId 5

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
# Fonction mysql avec mot de passe MySQL intégré (MYSQL_PWD)
# Retourne le chemin du fichier de preuve généré
# ---------------------------------------------------------------------------
mysql_exec() {
    local host="$1"; shift 1
    local sql="$*"
    local date_iso rc out proof
    proof="$PROOF_DIR/mysql_exec_$(date +%s%N).txt"
    date_iso=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    mkdir -p "$(dirname "$proof")"
    if [ -n "$host" ]; then
        out=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u root -h "$host" -e "$sql" 2>&1)
    else
        out=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u root -e "$sql" 2>&1)
    fi
    rc=$?
    {
        echo "# date: $date_iso"
        echo "# cmd: mysql -u root -h $host -e '$sql'"
        echo "# rc: $rc"
        echo "$out"
    } > "$proof"
    echo "[OK rc=$rc] $proof"
    echo "$proof"
    return $rc
}

# ---------------------------------------------------------------------------
# Vérification si le cluster est déjà démarré (via ndb_mgm SHOW sur IP1)
# ---------------------------------------------------------------------------
is_cluster_running() {
    local out
    out=$(SSHPASS="$PW1" sshpass -e ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 root@"$IP1" "ndb_mgm -e 'SHOW' 2>&1" || true)
    echo "$out" | grep -q "id=1.*@$IP1" && echo "$out" | grep -q "id=4.*@$IP1" && echo "$out" | grep -q "id=5.*@$IP3"
    return $?
}

# ---------------------------------------------------------------------------
# Vérification que MySQL répond sur un node SQL
# Retourne 0 si OK, 1 si échec
# ---------------------------------------------------------------------------
check_mysql_access() {
    local host="$1"; local label="$2"
    local out
    out=$(MYSQL_PWD="$MYSQL_PASSWORD" mysql -u root -h "$host" -e "SELECT 1 AS test;" 2>&1)
    local rc=$?
    if [ $rc -eq 0 ]; then
        echo "  ✅ MySQL $label ($host) : ACCÈS OK"
        return 0
    else
        echo "  ❌ MySQL $label ($host) : ACCÈS REFUSÉ"
        echo "     Erreur : $out"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Affichage d'une bannière
# ---------------------------------------------------------------------------
banner() {
    clear
    echo "================================================================"
    echo "  GESTIONNAIRE DE CLUSTER MYSQL NDB (v3)"
    echo "  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "================================================================"
    echo "  MySQL root password : ******** (intégré via MYSQL_PWD)"
    echo "  Répertoire de travail local : $WORKDIR"
    echo "  Preuves locales : $PROOF_DIR"
    echo ""
    echo "  Architecture cible :"
    echo "    NodeId 1 : ndb_mgmd   @ $IP1 (gestionnaire principal)"
    echo "    NodeId 2 : ndbd       @ $IP2 (stockage)"
    echo "    NodeId 3 : ndbd       @ $IP2 (stockage)"
    echo "    NodeId 4 : mysqld     @ $IP1 (SQL principal)"
    echo "    NodeId 5 : mysqld     @ $IP3 (SQL secondaire)"
    echo "================================================================"
}

# ---------------------------------------------------------------------------
# 1. PRÉ-VÉRIFICATION COMPLÈTE
# ---------------------------------------------------------------------------
precheck_all() {
    banner
    echo ">>> PRÉ-VÉRIFICATION COMPLÈTE DE LA CONFIGURATION NDB <<<"
    echo ""

    local step=1

    echo "[$step] Vérification config.ini sur $IP1"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/precheck_01_config_ini.txt" \
        "cat /var/lib/mysql-cluster/config.ini"
    step=$((step+1))

    echo "[$step] Processus sur $IP1 (ndb_mgmd + mysqld)"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/precheck_02_processus_vm1.txt" \
        "ps aux | grep -E 'ndb_mgmd|mysqld' | grep -v grep || echo 'AUCUN PROCESSUS NDB'"
    step=$((step+1))

    echo "[$step] Processus sur $IP2 (ndbd x2)"
    log_proof_ssh "$IP2" "$PW2" "$PROOF_DIR/precheck_03_processus_vm2.txt" \
        "ps aux | grep -E 'ndbd|ndbmtd' | grep -v grep || echo 'AUCUN PROCESSUS NDB'"
    step=$((step+1))

    echo "[$step] Processus sur $IP3 (mysqld)"
    log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/precheck_04_processus_vm3.txt" \
        "ps aux | grep mysqld | grep -v grep || echo 'AUCUN PROCESSUS MYSQLD'"
    step=$((step+1))

    echo "[$step] Connectivité réseau (ping $IP1 $IP2 $IP3)"
    log_proof "$PROOF_DIR/precheck_05_ping.txt" "ping -c 3 $IP1 && ping -c 3 $IP2 && ping -c 3 $IP3"
    step=$((step+1))

    echo "[$step] Ports 1186 et 3306 sur $IP1"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/precheck_06_ports_vm1.txt" \
        "ss -tlnp | grep -E '1186|3306' || netstat -tlnp | grep -E '1186|3306'"
    step=$((step+1))

    echo "[$step] Port 3306 sur $IP3"
    log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/precheck_07_ports_vm3.txt" \
        "ss -tlnp | grep 3306 || netstat -tlnp | grep 3306"
    step=$((step+1))

    echo "[$step] ndb_mgm SHOW sur $IP1"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/precheck_08_ndb_show.txt" \
        "ndb_mgm -e 'SHOW'"
    step=$((step+1))

    echo "[$step] ndb_mgm ALL STATUS sur $IP1"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/precheck_09_ndb_status.txt" \
        "ndb_mgm -e 'ALL STATUS'"
    step=$((step+1))

    echo "[$step] Test connexion MySQL NodeId 4 ($IP1)"
    check_mysql_access "$IP1" "NodeId 4"
    step=$((step+1))

    echo "[$step] Test connexion MySQL NodeId 5 ($IP3)"
    check_mysql_access "$IP3" "NodeId 5"

    echo ""
    echo ">>> PRÉ-VÉRIFICATION TERMINÉE <<<"
    echo "Logs dans : $PROOF_DIR/"
    read -p "Appuyez sur Entrée pour continuer..."
}

# ---------------------------------------------------------------------------
# 2. ARRÊT PROPRE DU CLUSTER
# ---------------------------------------------------------------------------
stop_cluster() {
    banner
    echo ">>> ARRÊT PROPRE DU CLUSTER NDB <<<"
    echo ""

    echo "Arrêt propre via ndb_mgm SHUTDOWN sur $IP1"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/stop_01_shutdown.txt" \
        "ndb_mgm -e 'SHUTDOWN' 2>&1 || true"
    sleep 5

    echo "Nettoyage processus résiduels sur $IP1"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/stop_02_kill_vm1.txt" \
        "pkill -x ndb_mgmd 2>/dev/null; pkill -x mysqld 2>/dev/null; sleep 2; echo 'nettoye vm1'"
    echo "Nettoyage processus résiduels sur $IP2"
    log_proof_ssh "$IP2" "$PW2" "$PROOF_DIR/stop_03_kill_vm2.txt" \
        "pkill -x ndbd 2>/dev/null; sleep 2; echo 'nettoye vm2'"
    echo "Nettoyage processus résiduels sur $IP3"
    log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/stop_04_kill_vm3.txt" \
        "pkill -x mysqld 2>/dev/null; sleep 2; echo 'nettoye vm3'"

    echo ""
    echo ">>> CLUSTER ARRÊTÉ <<<"
    read -p "Appuyez sur Entrée pour continuer..."
}

# ---------------------------------------------------------------------------
# 3. DÉMARRAGE ORDONNÉ DU CLUSTER
# ---------------------------------------------------------------------------
start_cluster() {
    banner
    echo ">>> DÉMARRAGE ORDONNÉ DU CLUSTER NDB <<<"
    echo ""

    # Vérifier si le cluster est déjà démarré pour éviter les doublons
    if is_cluster_running; then
        echo "⚠️  Le cluster semble déjà démarré sur $IP1"
        read -p "Continuer quand même ? (oui/non) : " conf
        if [ "$conf" != "oui" ]; then
            echo "Annulé."
            read -p "Appuyez sur Entrée pour continuer..."
            return
        fi
    fi

    echo "1/5 — Démarrage ndb_mgmd (NodeId 1) sur $IP1"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/start_01_ndb_mgmd.txt" \
        "ndb_mgmd --config-file=/var/lib/mysql-cluster/config.ini; echo 'MGMD-RC='$?"
    sleep 3

    echo "2/5 — Démarrage ndbd NodeId 2 sur $IP2"
    log_proof_ssh "$IP2" "$PW2" "$PROOF_DIR/start_02_ndbd_node2.txt" \
        "cd /var/lib/mysql-cluster/ndb_2 && nohup ndbd --ndb-connectstring=$IP1 > ndbd_2.log 2>&1 & echo 'NBD2-STARTED'"
    echo "3/5 — Démarrage ndbd NodeId 3 sur $IP2"
    log_proof_ssh "$IP2" "$PW2" "$PROOF_DIR/start_03_ndbd_node3.txt" \
        "cd /var/lib/mysql-cluster/ndb_3 && nohup ndbd --ndb-connectstring=$IP1 > ndbd_3.log 2>&1 & echo 'NBD3-STARTED'"
    sleep 5

    echo "4/5 — Démarrage mysqld NodeId 4 sur $IP1"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/start_04_mysqld_node4.txt" \
        "mysqld --ndbcluster --ndb-connectstring=$IP1 --user=mysql --daemonize > /tmp/mysqld-4.log 2>&1; echo 'MYSQLD4-RC='$?"
    echo "5/5 — Démarrage mysqld NodeId 5 sur $IP3"
    log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/start_05_mysqld_node5.txt" \
        "mysqld --ndbcluster --ndb-connectstring=$IP1 --user=mysql --daemonize > /tmp/mysqld-5.log 2>&1; echo 'MYSQLD5-RC='$?"
    sleep 5

    echo ""
    echo ">>> CLUSTER DÉMARRÉ <<<"
    read -p "Appuyez sur Entrée pour continuer..."
}

# ---------------------------------------------------------------------------
# 4. REDÉMARRAGE COMPLET DU CLUSTER
# ---------------------------------------------------------------------------
restart_cluster() {
    stop_cluster
    start_cluster
}

# ---------------------------------------------------------------------------
# 5. STATUT DU CLUSTER
# ---------------------------------------------------------------------------
status_cluster() {
    banner
    echo ">>> STATUT DU CLUSTER NDB <<<"
    echo ""
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/status_01_show.txt" \
        "ndb_mgm -e 'SHOW'"
    echo ""
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/status_02_all_status.txt" \
        "ndb_mgm -e 'ALL STATUS'"
    echo ""
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/status_03_memory.txt" \
        "ndb_mgm -e 'ALL REPORT MEMORYUSAGE'"
    echo ""
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/status_04_config.txt" \
        "ndb_config --query-all 2>&1 | grep -E 'NodeId|HostName|NoOfReplicas'"
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# ---------------------------------------------------------------------------
# 6. CORRECTION ACCÈS MYSQL INTER-NODES (root@%)
# ---------------------------------------------------------------------------
fix_mysql_access() {
    banner
    echo ">>> CORRECTION ACCÈS MYSQL INTER-NODES (root@%) <<<"
    echo ""
    echo "Cette opération crée ou met à jour l'utilisateur 'root'@'%'"
    echo "sur chaque node SQL avec le mot de '$MYSQL_PASSWORD'."
    echo ""
    echo "Vous devez connaître le mot de passe root actuel de chaque node"
    echo "pour vous connecter en local (socket) avant d'appliquer le changement."
    echo ""

    echo "1/2 — Corriger l'accès MySQL sur $IP1 (NodeId 4)"
    echo "   Connexion locale (socket) pour modifier root@%..."
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/fix_mysql_01_vm1.txt" \
        "mysql -u root -p -e \"ALTER USER 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;\" 2>&1 || echo 'ÉCHEC — vérifier le mot de passe root local sur $IP1'"

    echo ""
    echo "2/2 — Corriger l'accès MySQL sur $IP3 (NodeId 5)"
    echo "   Connexion locale (socket) pour modifier root@%..."
    log_proof_ssh "$IP3" "$PW3" "$PROOF_DIR/fix_mysql_02_vm3.txt" \
        "mysql -u root -p -e \"ALTER USER 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;\" 2>&1 || echo 'ÉCHEC — vérifier le mot de passe root local sur $IP3'"

    echo ""
    echo ">>> VÉRIFICATION DES CONNEXIONS INTER-NODES <<<"
    echo ""
    echo "Test 10.0.0.199 → 10.0.0.210 :"
    MYSQL_PWD="$MYSQL_PASSWORD" mysql -u root -h "$IP3" -e "SELECT 1 AS test_connexion_199_to_210;" 2>&1 || echo "  ❌ ÉCHEC"
    echo ""
    echo "Test 10.0.0.210 → 10.0.0.199 :"
    MYSQL_PWD="$MYSQL_PASSWORD" mysql -u root -h "$IP1" -e "SELECT 1 AS test_connexion_210_to_199;" 2>&1 || echo "  ❌ ÉCHEC"

    echo ""
    echo ">>> CORRECTION TERMINÉE <<<"
    read -p "Appuyez sur Entrée pour continuer..."
}

# ---------------------------------------------------------------------------
# 6. TEST DE SYNCHRONISATION ENTRE TOUS LES NODES SQL (bidirectionnel)
# ---------------------------------------------------------------------------
test_sync() {
    banner
    echo ">>> TEST DE SYNCHRONISATION NDB ENTRE TOUS LES NODES SQL <<<"
    echo ""

    # -----------------------------------------------------------------------
    # Vérification préalable de l'accès MySQL sur les deux nodes SQL
    # -----------------------------------------------------------------------
    echo "VÉRIFICATION PRÉALABLE : Accès MySQL sur les nodes SQL"
    echo "-------------------------------------------------------"

    local mysql_ok=0
    check_mysql_access "$IP1" "NodeId 4" || mysql_ok=1
    check_mysql_access "$IP3" "NodeId 5" || mysql_ok=1

    if [ "$mysql_ok" -ne 0 ]; then
        echo ""
        echo "❌ L'accès MySQL inter-nodes n'est pas configuré correctement."
        echo "   Utilisez l'option 6 du menu pour corriger l'accès root@% sur les deux nodes."
        echo "   Puis relancez ce test."
        read -p "Appuyez sur Entrée pour continuer..."
        return
    fi

    echo ""
    echo "Accès MySQL OK sur les deux nodes. Démarrage du test de synchronisation."
    echo ""

    local sync_ok=0

    # -----------------------------------------------------------------------
    # ÉTAPE 1 — SHOW (état du cluster)
    # -----------------------------------------------------------------------
    echo "1/6 — SHOW (tous les nœuds)"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/sync_01_show.txt" \
        "ndb_mgm -e 'SHOW'"

    # -----------------------------------------------------------------------
    # ÉTAPE 2 — INSERT sur NodeId 4 ($IP1) → SELECT sur NodeId 5 ($IP3)
    # -----------------------------------------------------------------------
    echo "2/6 — INSERT sur NodeId 4 ($IP1) → lecture sur NodeId 5 ($IP3)"
    local p1 p2
    p1=$(mysql_exec "$IP1" "CREATE DATABASE IF NOT EXISTS test_replica; USE test_replica; DROP TABLE IF EXISTS test_sync_bidi; CREATE TABLE test_sync_bidi (id INT PRIMARY KEY AUTO_INCREMENT, msg VARCHAR(200), source_node INT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=ndbcluster; INSERT INTO test_sync_bidi (msg, source_node) VALUES ('ecrit sur NodeId 4 $(date -u '+%Y-%m-%dT%H:%M:%SZ')', 4); SELECT * FROM test_sync_bidi ORDER BY id DESC LIMIT 3;")
    echo "  -> Fichier INSERT Node4 : $p1"
    cat "$p1"

    echo ""
    echo "3/6 — SELECT sur NodeId 5 ($IP3) (vérifie réplication depuis NodeId 4)"
    p2=$(mysql_exec "$IP3" "USE test_replica; SELECT * FROM test_sync_bidi ORDER BY id DESC LIMIT 3;")
    echo "  -> Fichier SELECT Node5 : $p2"
    cat "$p2"

    # Vérifier que la ligne apparaît sur NodeId 5
    if grep -q "ecrit sur NodeId 4" "$p2" 2>/dev/null; then
        echo "  ✅ SYNCHRONISATION NodeId 4 -> NodeId 5 : OK"
    else
        echo "  ❌ SYNCHRONISATION NodeId 4 -> NodeId 5 : ÉCHEC (ligne introuvable sur NodeId 5)"
        sync_ok=1
    fi

    # -----------------------------------------------------------------------
    # ÉTAPE 4 — INSERT sur NodeId 5 ($IP3) → SELECT sur NodeId 4 ($IP1)
    # -----------------------------------------------------------------------
    echo ""
    echo "4/6 — INSERT sur NodeId 5 ($IP3) → lecture sur NodeId 4 ($IP1)"
    local p3 p4
    p3=$(mysql_exec "$IP3" "USE test_replica; INSERT INTO test_sync_bidi (msg, source_node) VALUES ('ecrit sur NodeId 5 $(date -u '+%Y-%m-%dT%H:%M:%SZ')', 5); SELECT * FROM test_sync_bidi ORDER BY id DESC LIMIT 3;")
    echo "  -> Fichier INSERT Node5 : $p3"
    cat "$p3"

    echo ""
    echo "5/6 — SELECT sur NodeId 4 ($IP1) (vérifie réplication depuis NodeId 5)"
    p4=$(mysql_exec "$IP1" "USE test_replica; SELECT * FROM test_sync_bidi ORDER BY id DESC LIMIT 3;")
    echo "  -> Fichier SELECT Node4 : $p4"
    cat "$p4"

    # Vérifier que la ligne apparaît sur NodeId 4
    if grep -q "ecrit sur NodeId 5" "$p4" 2>/dev/null; then
        echo "  ✅ SYNCHRONISATION NodeId 5 -> NodeId 4 : OK"
    else
        echo "  ❌ SYNCHRONISATION NodeId 5 -> NodeId 4 : ÉCHEC (ligne introuvable sur NodeId 4)"
        sync_ok=1
    fi

    # -----------------------------------------------------------------------
    # ÉTAPE 6 — ndb_desc (distribution des fragments NDB)
    # -----------------------------------------------------------------------
    echo ""
    echo "6/6 — ndb_desc (distribution des fragments NDB)"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/sync_06_ndb_desc.txt" \
        "ndb_desc --ndb-connectstring=$IP1 test_replica.test_sync_bidi"

    # -----------------------------------------------------------------------
    # RÉSUMÉ
    # -----------------------------------------------------------------------
    echo ""
    echo "================================================================"
    echo "  RÉSUMÉ DU TEST DE SYNCHRONISATION BIDIRECTIONNEL"
    echo "================================================================"
    if [ "$sync_ok" -eq 0 ]; then
        echo "  ✅ TOUS LES TESTS DE SYNCHRONISATION SONT OK"
        echo "     Les données écrites sur un node SQL sont visibles sur tous les autres."
    else
        echo "  ❌ DES ERREURS DE SYNCHRONISATION ONT ÉTÉ DÉTECTÉES"
        echo "     Consultez les fichiers de preuve pour diagnostiquer."
    fi
    echo "================================================================"
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# ---------------------------------------------------------------------------
# 7. NETTOYAGE DES RÉPERTOIRES DE DONNÉES (repartir de zéro)
# ---------------------------------------------------------------------------
clean_datadir() {
    banner
    echo "⚠️  NETTOYAGE DES RÉPERTOIRES DE DONNÉES NDB ⚠️"
    echo ""
    echo "ATTENTION : Cette opération SUPPRIME toutes les données NDB !"
    echo "Répertoires concernés :"
    echo "  $IP1 : /var/lib/mysql-cluster/*"
    echo "  $IP2 : /var/lib/mysql-cluster/ndb_2 et ndb_3"
    echo ""
    read -p "Taper 'OUI' pour confirmer : " conf
    if [ "$conf" != "OUI" ]; then
        echo "Annulé."
        read -p "Appuyez sur Entrée pour continuer..."
        return
    fi

    echo "Nettoyage $IP1"
    log_proof_ssh "$IP1" "$PW1" "$PROOF_DIR/clean_01_vm1.txt" \
        "rm -rf /var/lib/mysql-cluster/* && mkdir -p /var/lib/mysql-cluster && ls -la /var/lib/mysql-cluster/"
    echo "Nettoyage $IP2"
    log_proof_ssh "$IP2" "$PW2" "$PROOF_DIR/clean_02_vm2.txt" \
        "rm -rf /var/lib/mysql-cluster/ndb_2 /var/lib/mysql-cluster/ndb_3 && mkdir -p /var/lib/mysql-cluster/ndb_2 /var/lib/mysql-cluster/ndb_3 && ls -la /var/lib/mysql-cluster/"
    echo ">>> NETTOYAGE TERMINÉ <<<"
    read -p "Appuyez sur Entrée pour continuer..."
}

# ---------------------------------------------------------------------------
# 8. CONSULTATION DES LOGS
# ---------------------------------------------------------------------------
view_logs() {
    banner
    echo ">>> CONSULTATION DES LOGS <<<"
    echo ""
    echo "Fichiers disponibles dans $PROOF_DIR/ :"
    ls -la "$PROOF_DIR/" 2>/dev/null || echo "Aucun fichier"
    echo ""
    read -p "Nom du fichier à afficher (ou vide pour retour) : " fname
    if [ -n "$fname" ] && [ -f "$PROOF_DIR/$fname" ]; then
        echo "================================================================"
        echo "  CONTENU DE : $fname"
        echo "================================================================"
        cat "$PROOF_DIR/$fname"
        echo "================================================================"
    fi
    read -p "Appuyez sur Entrée pour continuer..."
}

# ---------------------------------------------------------------------------
# MENU PRINCIPAL
# ---------------------------------------------------------------------------
main_menu() {
    while true; do
        banner
        echo ""
        echo "  MENU PRINCIPAL"
        echo "  --------------"
        echo "  1. Pré-vérification complète (config, processus, ports, MySQL)"
        echo "  2. Arrêt propre du cluster (SHUTDOWN + nettoyage processus)"
        echo "  3. Démarrage ordonné du cluster (mgmd -> ndbd -> mysqld)"
        echo "  4. Redémarrage complet du cluster"
        echo "  5. Statut du cluster (SHOW, ALL STATUS, MEMORYUSAGE)"
        echo "  6. Corriger accès MySQL inter-nodes (root@%)"
        echo "  7. Test de synchronisation bidirectionnel (écriture sur tous les nodes SQL)"
        echo "  8. Nettoyage des répertoires de données (ATTENTION : supprime tout)"
        echo "  9. Consulter les logs de preuve"
        echo "  10. Quitter"
        echo ""
        read -p "Choix [1-10] : " choice

        case $choice in
            1) precheck_all ;;
            2) stop_cluster ;;
            3) start_cluster ;;
            4) restart_cluster ;;
            5) status_cluster ;;
            6) fix_mysql_access ;;
            7) test_sync ;;
            8) clean_datadir ;;
            9) view_logs ;;
            10) echo "Au revoir !"; exit 0 ;;
            *) echo "Choix invalide."; sleep 1 ;;
        esac
    done
}

# ---------------------------------------------------------------------------
# POINT D'ENTRÉE
# ---------------------------------------------------------------------------
main_menu
