#!/bin/bash
# Lab-02 : Installation des paquets MySQL Cluster sur les 3 VM.
# Generation de preuves avec en-tetes # date:, # cmd:, # rc=.
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
    echo "[OK rc=$rc] $proof"
}

echo "========== LAB-02 : Installation VM 1 (gestion + SQL) =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/apt-install-vm1.txt" \
    "DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-cluster-community-management-server mysql-cluster-community-server 2>&1 | tail -40; echo 'FIN-INSTALL-VM1'"

echo "========== LAB-02 : Installation VM 2 (data node) =========="
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/apt-install-vm2.txt" \
    "DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-cluster-community-data-node 2>&1 | tail -40; echo 'FIN-INSTALL-VM2'"

echo "========== LAB-02 : Installation VM 3 (SQL) =========="
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/apt-install-vm3.txt" \
    "DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-cluster-community-server 2>&1 | tail -40; echo 'FIN-INSTALL-VM3'"

echo "========== LAB-02 : Verification dpkg post-install =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/dpkg-ndb-gestion-sql.txt" "dpkg -l 2>/dev/null | grep -i -E 'mysql-cluster|ndb' || echo 'aucun paquet ndb'"
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/dpkg-ndb-stockage.txt" "dpkg -l 2>/dev/null | grep -i -E 'mysql-cluster|ndb' || echo 'aucun paquet ndb'"
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/dpkg-ndb-mysql-node3.txt" "dpkg -l 2>/dev/null | grep -i -E 'mysql-cluster|ndb' || echo 'aucun paquet ndb'"

echo "========== LAB-02 : Verification binaires =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/which-binaries-vm1.txt" "which ndb_mgmd ndb_mgm mysqld 2>&1; ls -la /usr/sbin/ndb_mgmd /usr/sbin/ndb_mgm /usr/sbin/mysqld 2>&1"
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/which-binaries-vm2.txt" "which ndbmtd 2>&1; ls -la /usr/sbin/ndbmtd 2>&1"
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/which-binaries-vm3.txt" "which mysqld 2>&1; ls -la /usr/sbin/mysqld 2>&1"

echo "Termine installation Lab-02."
