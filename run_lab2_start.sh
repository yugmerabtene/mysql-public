#!/bin/bash
# Lab-02 : config.ini, repertoire de donnees, demarrage ordonne, verification cluster.
# Generation de preuves avec en-tetes # date:, # cmd:, # rc=.
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
    echo "[OK rc=$rc] $proof"
}

run_proof_host() {
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
}

echo "========== LAB-02 : Creer repertoire /var/lib/mysql-cluster sur VM1 =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/repertoire-cluster-vm1.txt" \
    "mkdir -p /var/lib/mysql-cluster && ls -la /var/lib/mysql-cluster/"

echo "========== LAB-02 : Installer config.ini sur VM1 =========="
scp $SSH_OPTS -o ConnectTimeout=15 "$CONFIG_INI" "root@$IP1:/var/lib/mysql-cluster/config.ini" 2>&1
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/config-ini.txt" \
    "cat /var/lib/mysql-cluster/config.ini"

echo "========== LAB-02 : Creer repertoires de donnees VM2 (ndb_2, ndb_3) =========="
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/repertoires-donnees-vm2.txt" \
    "mkdir -p /var/lib/mysql-cluster/ndb_2 /var/lib/mysql-cluster/ndb_3 && ls -la /var/lib/mysql-cluster/"

echo "========== LAB-02 : Demarrer ndb_mgmd sur VM1 (NodeId 1) =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/ndb-mgmd-start.txt" \
    "ndb_mgmd --config-file=/var/lib/mysql-cluster/config.ini --initial; echo 'MGMD-RC='$?"

sleep 3

echo "========== LAB-02 : Demarrer ndbmtd NodeId 2 sur VM2 =========="
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/ndbmtd-start-node2.txt" \
    "cd /var/lib/mysql-cluster/ndb_2 && nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_2.log 2>&1 & echo 'NDBMTD2-STARTED'"

echo "========== LAB-02 : Demarrer ndbmtd NodeId 3 sur VM2 =========="
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/ndbmtd-start-node3.txt" \
    "cd /var/lib/mysql-cluster/ndb_3 && nohup ndbmtd --ndb-connectstring=192.168.56.10 --initial > ndbmtd_3.log 2>&1 & echo 'NDBMTD3-STARTED'"

sleep 5

echo "========== LAB-02 : Demarrer mysqld NodeId 4 sur VM1 =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/mysqld-start-vm1.txt" \
    "mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize > /tmp/mysqld-4.log 2>&1; echo 'MYSQLD4-RC='$?"

echo "========== LAB-02 : Demarrer mysqld NodeId 5 sur VM3 =========="
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/mysqld-start-vm3.txt" \
    "mysqld --ndbcluster --ndb-connectstring=192.168.56.10 --user=mysql --daemonize > /tmp/mysqld-5.log 2>&1; echo 'MYSQLD5-RC='$?"

sleep 5

echo "========== LAB-02 : Verification ndb_mgm SHOW =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/ndb-show.txt" \
    "ndb_mgm -e 'SHOW'; echo 'SHOW-RC='$?"

echo "========== LAB-02 : Verification ndb_config NoOfReplicas =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/ndb-config.txt" \
    "ndb_config --query-all 2>&1 | grep -E 'NodeId|HostName|NoOfReplicas'; echo 'CONFIG-RC='$?"

echo "========== LAB-02 : Processus finaux sur chaque VM =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/processus-finaux-gestion-sql.txt" \
    "ps aux | grep -E 'ndb_mgmd|mysqld' | grep -v grep"
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/processus-finaux-stockage.txt" \
    "ps aux | grep -E 'ndbmtd' | grep -v grep"
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/processus-finaux-mysql-node3.txt" \
    "ps aux | grep -E 'mysqld' | grep -v grep"

echo "Termine demarrage et verification Lab-02."
