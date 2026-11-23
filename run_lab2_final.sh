#!/bin/bash
# Lab-02 : Démarrage FINAL du cluster avec config.ini (NoOfReplicas=2).
# Ordre : nettoyage -> copie config.ini -> ndb_mgmd --initial -> ndbmtd --initial x2 -> mysqld x2 -> verification.
set -u

WORKDIR="/home/yug/Documents/mysql"
ENV_FILE="$WORKDIR/.env"
PROOF_DIR="$WORKDIR/preuves"
CONFIG_INI="$WORKDIR/config.ini"

get_pw() {
    local vm="$1"
    grep "^SSH_PASSWORD_VM${vm}=" "$ENV_FILE" | cut -d= -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

PW1=$(get_pw 1); PW2=$(get_pw 2); PW3=$(get_pw 3)
IP1="192.168.56.10"; IP2="192.168.56.11"; IP3="192.168.56.12"
SSH_OPTS="-o StrictHostKeyChecking=accept-new -o ConnectTimeout=15"

run_proof() {
    local ip="$1" pw="$2" proof="$3"; shift 3
    local cmd="$*"
    local date_iso rc out
    date_iso=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    mkdir -p "$(dirname "$proof")"
    out=$(SSHPASS="$pw" sshpass -e ssh $SSH_OPTS root@"$ip" "$cmd" 2>&1)
    rc=$?
    {
        echo "# date: $date_iso"
        echo "# cmd: ssh root@$ip $cmd"
        echo "# rc: $rc"
        echo "$out"
    } > "$proof"
    echo "[OK ssh-rc=$rc] $proof"
}

echo "========== FINAL : Verifier/supprimer processus residuels =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/final-kill-vm1.txt" "pkill -x ndb_mgmd 2>/dev/null; pkill -x mysqld 2>/dev/null; sleep 1; echo done-vm1"
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/final-kill-vm2.txt" "pkill -x ndbmtd 2>/dev/null; sleep 1; echo done-vm2"
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/final-kill-vm3.txt" "pkill -x mysqld 2>/dev/null; sleep 1; echo done-vm3"

echo "========== FINAL : Nettoyer repertoires de donnees =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/final-clean-vm1.txt" \
    "rm -rf /var/lib/mysql-cluster/* /var/lib/mysql-cluster/ndb_* 2>/dev/null; mkdir -p /var/lib/mysql-cluster; ls -la /var/lib/mysql-cluster/"
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/final-clean-vm2.txt" \
    "rm -rf /var/lib/mysql-cluster/ndb_2 /var/lib/mysql-cluster/ndb_3 2>/dev/null; mkdir -p /var/lib/mysql-cluster/ndb_2 /var/lib/mysql-cluster/ndb_3; ls -la /var/lib/mysql-cluster/"

echo "========== FINAL : Copier config.ini sur VM1 (APRES nettoyage) =========="
SSHPASS="$PW1" sshpass -e ssh $SSH_OPTS root@"$IP1" "cat > /var/lib/mysql-cluster/config.ini" < "$CONFIG_INI" 2>&1
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/config-ini.txt" \
    "cat /var/lib/mysql-cluster/config.ini"

echo "========== FINAL : Demarrer ndb_mgmd --initial sur VM1 (NodeId 1) =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/ndb-mgmd-start.txt" \
    "ndb_mgmd --config-file=/var/lib/mysql-cluster/config.ini --initial; echo MGMD_RC=\$?"

sleep 4

echo "========== FINAL : Demarrer ndbmtd --initial NodeId 2 sur VM2 =========="
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/ndbmtd-start-node2.txt" \
    "cd /var/lib/mysql-cluster/ndb_2 && nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_2.log 2>&1 & echo NDBMTD2_STARTED"

echo "========== FINAL : Demarrer ndbmtd --initial NodeId 3 sur VM2 =========="
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/ndbmtd-start-node3.txt" \
    "cd /var/lib/mysql-cluster/ndb_3 && nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_3.log 2>&1 & echo NDBMTD3_STARTED"

sleep 7

echo "========== FINAL : Demarrer mysqld NodeId 4 sur VM1 =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/mysqld-start-vm1.txt" \
    "rm -f /tmp/mysqld-4.log; mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize > /tmp/mysqld-4.log 2>&1; echo MYSQLD4_RC=\$?"

echo "========== FINAL : Demarrer mysqld NodeId 5 sur VM3 =========="
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/mysqld-start-vm3.txt" \
    "rm -f /tmp/mysqld-5.log; mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize > /tmp/mysqld-5.log 2>&1; echo MYSQLD5_RC=\$?"

sleep 7

echo "========== FINAL : Verification ndb_mgm SHOW =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/ndb-show.txt" \
    "ndb_mgm -e 'SHOW'; echo SHOW_RC=\$?"

echo "========== FINAL : Verification ndb_config NoOfReplicas =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/ndb-config.txt" \
    "ndb_config --query-all 2>&1 | grep -E 'NodeId|HostName|NoOfReplicas'; echo CONFIG_RC=\$?"

echo "========== FINAL : Memoire usage =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/ndb-memory.txt" \
    "ndb_mgm -e 'ALL REPORT MEMORYUSAGE' 2>&1; echo MEM_RC=\$?"

echo "========== FINAL : Processus finaux =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/processus-finaux-gestion-sql.txt" \
    "ps aux | grep -E 'ndb_mgmd|mysqld' | grep -v grep"
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/processus-finaux-stockage.txt" \
    "ps aux | grep -E 'ndbmtd' | grep -v grep"
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/processus-finaux-mysql-node3.txt" \
    "ps aux | grep -E 'mysqld' | grep -v grep"

echo "========== FINAL : Ports en ecoute =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/port1186-vm1.txt" "ss -tlnp 2>/dev/null | grep 1186 || netstat -tlnp 2>/dev/null | grep 1186; echo PORT1186_RC=\$?"
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/port3306-vm1.txt" "ss -tlnp 2>/dev/null | grep 3306 || netstat -tlnp 2>/dev/null | grep 3306; echo PORT3306_RC=\$?"
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/port3306-vm3.txt" "ss -tlnp 2>/dev/null | grep 3306 || netstat -tlnp 2>/dev/null | grep 3306; echo PORT3306_RC=\$?"

echo "Termine demarrage FINAL Lab-02."
