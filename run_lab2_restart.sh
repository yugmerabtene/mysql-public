#!/bin/bash
# Lab-02 : Redemarrage propre du cluster avec config.ini (NoOfReplicas=2).
# Arret, nettoyage, demarrage ordonne, verification. Preuves avec en-tetes.
set -u

WORKDIR="/home/yug/Documents/mysql"
ENV_FILE="$WORKDIR/.env"
PROOF_DIR="$WORKDIR/preuves"

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

echo "========== LAB-02-RESTART : Arret propre du cluster (ndb_mgm SHUTDOWN) =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/cluster-shutdown.txt" \
    "ndb_mgm -e 'SHUTDOWN' 2>&1 || true; sleep 3"

echo "========== LAB-02-RESTART : Tuer processus residuels sur toutes les VM =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/kill-vm1.txt" "pkill -x ndb_mgmd 2>/dev/null; pkill -x mysqld 2>/dev/null; sleep 1; echo killed-vm1"
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/kill-vm2.txt" "pkill -x ndbmtd 2>/dev/null; sleep 1; echo killed-vm2"
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/kill-vm3.txt" "pkill -x mysqld 2>/dev/null; sleep 1; echo killed-vm3"

echo "========== LAB-02-RESTART : Nettoyer repertoires de donnees VM1 et VM2 =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/clean-datadir-vm1.txt" \
    "rm -rf /var/lib/mysql-cluster/* && mkdir -p /var/lib/mysql-cluster && ls -la /var/lib/mysql-cluster/"
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/clean-datadir-vm2.txt" \
    "rm -rf /var/lib/mysql-cluster/ndb_2 /var/lib/mysql-cluster/ndb_3 && mkdir -p /var/lib/mysql-cluster/ndb_2 /var/lib/mysql-cluster/ndb_3 && ls -la /var/lib/mysql-cluster/"

echo "========== LAB-02-RESTART : Verifier config.ini sur VM1 =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/config-ini.txt" \
    "cat /var/lib/mysql-cluster/config.ini"

echo "========== LAB-02-RESTART : Demarrer ndb_mgmd --initial sur VM1 (NodeId 1) =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/ndb-mgmd-start.txt" \
    "ndb_mgmd --config-file=/var/lib/mysql-cluster/config.ini --initial; echo 'MGMD-RC='$?"

sleep 4

echo "========== LAB-02-RESTART : Demarrer ndbmtd --initial NodeId 2 sur VM2 =========="
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/ndbmtd-start-node2.txt" \
    "cd /var/lib/mysql-cluster/ndb_2 && nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_2.log 2>&1 & echo 'NDBMTD2-STARTED'"

echo "========== LAB-02-RESTART : Demarrer ndbmtd --initial NodeId 3 sur VM2 =========="
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/ndbmtd-start-node3.txt" \
    "cd /var/lib/mysql-cluster/ndb_3 && nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_3.log 2>&1 & echo 'NDBMTD3-STARTED'"

sleep 6

echo "========== LAB-02-RESTART : Demarrer mysqld NodeId 4 sur VM1 =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/mysqld-start-vm1.txt" \
    "mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize > /tmp/mysqld-4.log 2>&1; echo 'MYSQLD4-RC='$?"

echo "========== LAB-02-RESTART : Demarrer mysqld NodeId 5 sur VM3 =========="
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/mysqld-start-vm3.txt" \
    "mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize > /tmp/mysqld-5.log 2>&1; echo 'MYSQLD5-RC='$?"

sleep 6

echo "========== LAB-02-RESTART : Verification ndb_mgm SHOW =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/ndb-show.txt" \
    "ndb_mgm -e 'SHOW'; echo 'SHOW-RC='$?"

echo "========== LAB-02-RESTART : Verification ndb_config NoOfReplicas =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/ndb-config.txt" \
    "ndb_config --query-all 2>&1 | grep -E 'NodeId|HostName|NoOfReplicas'; echo 'CONFIG-RC='$?"

echo "========== LAB-02-RESTART : Memoire usage =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/ndb-memory.txt" \
    "ndb_mgm -e 'ALL REPORT MEMORYUSAGE' 2>&1; echo 'MEM-RC='$?"

echo "========== LAB-02-RESTART : Processus finaux =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/processus-finaux-gestion-sql.txt" \
    "ps aux | grep -E 'ndb_mgmd|mysqld' | grep -v grep"
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/processus-finaux-stockage.txt" \
    "ps aux | grep -E 'ndbmtd' | grep -v grep"
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/processus-finaux-mysql-node3.txt" \
    "ps aux | grep -E 'mysqld' | grep -v grep"

echo "Termine redemarrage et verification Lab-02."
