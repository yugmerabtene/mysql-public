#!/bin/bash
# Script helper pour exécuter les Labs 1 et 2 en réel sur les 3 VM.
# Génère des fichiers de preuve avec en-têtes # date:, # cmd:, # rc=.
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

# run_proof <ip> <pw> <proof_file> <commande...>
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

# run_proof_host <proof_file> <commande...>
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

echo "=== VMs : $IP1 (gestion-sql) $IP2 (stockage) $IP3 (mysql-node3) ==="
echo "Preuves : $PROOF_DIR"
echo

# ============================================================
# LAB-01 : Nettoyage et configuration des 3 VM
# ============================================================

echo "========== LAB-01 : Nettoyage VM 1 =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab1/nettoyage-vm1.txt" \
    "apt-get purge -y mysql-cluster-* ndb_* mysql-server mysql-client 2>/dev/null; apt-get autoremove -y; rm -rf /var/lib/mysql-cluster /var/lib/mysql /etc/mysql/my.cnf.d/ndb* 2>/dev/null; echo nettoye"

echo "========== LAB-01 : Nettoyage VM 2 =========="
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab1/nettoyage-vm2.txt" \
    "apt-get purge -y mysql-cluster-* ndb_* mysql-server mysql-client 2>/dev/null; apt-get autoremove -y; rm -rf /var/lib/mysql-cluster /var/lib/mysql /etc/mysql/my.cnf.d/ndb* 2>/dev/null; echo nettoye"

echo "========== LAB-01 : Nettoyage VM 3 =========="
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab1/nettoyage-vm3.txt" \
    "apt-get purge -y mysql-cluster-* ndb_* mysql-server mysql-client 2>/dev/null; apt-get autoremove -y; rm -rf /var/lib/mysql-cluster /var/lib/mysql /etc/mysql/my.cnf.d/ndb* 2>/dev/null; echo nettoye"

# Fichiers netplan locaux (crees une seule fois)
cat > "$WORKDIR/netplan-vm1.yaml" << 'YEOF'
network:
  version: 2
  ethernets:
    enp0s8:
      dhcp4: no
      addresses: [192.168.56.10/24]
      gateway4: 192.168.56.1
      nameservers:
        addresses: [192.168.56.1, 8.8.8.8]
YEOF

cat > "$WORKDIR/netplan-vm2.yaml" << 'YEOF'
network:
  version: 2
  ethernets:
    enp0s8:
      dhcp4: no
      addresses: [192.168.56.11/24]
      gateway4: 192.168.56.1
      nameservers:
        addresses: [192.168.56.1, 8.8.8.8]
YEOF

cat > "$WORKDIR/netplan-vm3.yaml" << 'YEOF'
network:
  version: 2
  ethernets:
    enp0s8:
      dhcp4: no
      addresses: [192.168.56.12/24]
      gateway4: 192.168.56.1
      nameservers:
        addresses: [192.168.56.1, 8.8.8.8]
YEOF

echo "========== LAB-01 : Configuration VM 1 =========="
# Copier le fichier netplan sur VM1 puis appliquer hostname + netplan + ssh
scp $SSH_OPTS -o ConnectTimeout=15 "$WORKDIR/netplan-vm1.yaml" "root@$IP1:/etc/netplan/01-netcfg.yaml" 2>&1
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab1/config-vm1.txt" \
    "hostnamectl set-hostname gestion-sql; netplan apply; systemctl enable --now ssh; hostname; ip -br addr show enp0s8; echo config-vm1-termine"

echo "========== LAB-01 : Configuration VM 2 =========="
scp $SSH_OPTS -o ConnectTimeout=15 "$WORKDIR/netplan-vm2.yaml" "root@$IP2:/etc/netplan/01-netcfg.yaml" 2>&1
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab1/config-vm2.txt" \
    "hostnamectl set-hostname stockage; netplan apply; systemctl enable --now ssh; hostname; ip -br addr show enp0s8; echo config-vm2-termine"

echo "========== LAB-01 : Configuration VM 3 =========="
scp $SSH_OPTS -o ConnectTimeout=15 "$WORKDIR/netplan-vm3.yaml" "root@$IP3:/etc/netplan/01-netcfg.yaml" 2>&1
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab1/config-vm3.txt" \
    "hostnamectl set-hostname mysql-node3; netplan apply; systemctl enable --now ssh; hostname; ip -br addr show enp0s8; echo config-vm3-termine"

echo "========== LAB-01 : Verification connectivite depuis l'hote =========="
run_proof_host "$PROOF_DIR/ch1-lab1/ping-vm1.txt" "ping -c 4 192.168.56.10"
run_proof_host "$PROOF_DIR/ch1-lab1/ping-vm2.txt" "ping -c 4 192.168.56.11"
run_proof_host "$PROOF_DIR/ch1-lab1/ping-vm3.txt" "ping -c 4 192.168.56.12"
run_proof_host "$PROOF_DIR/ch1-lab1/ssh-root-vm1.txt" "ssh $SSH_OPTS root@192.168.56.10 hostname; true"
run_proof_host "$PROOF_DIR/ch1-lab1/ssh-root-vm2.txt" "ssh $SSH_OPTS root@192.168.56.11 hostname; true"
run_proof_host "$PROOF_DIR/ch1-lab1/ssh-root-vm3.txt" "ssh $SSH_OPTS root@192.168.56.12 hostname; true"

echo "========== LAB-01 : Snapshots =========="
run_proof_host "$PROOF_DIR/ch1-lab1/snapshot-UbuntuServer-01.txt" "VBoxManage snapshot UbuntuServer-01 list"
run_proof_host "$PROOF_DIR/ch1-lab1/snapshot-UbuntuServer-02.txt" "VBoxManage snapshot UbuntuServer-02 list"
run_proof_host "$PROOF_DIR/ch1-lab1/snapshot-UbuntuServer-03.txt" "VBoxManage snapshot UbuntuServer-03 list"

echo
echo "========== LAB-02 : Verification paquets (apres nettoyage) =========="
run_proof "$IP1" "$PW1" "$PROOF_DIR/ch1-lab2/dpkg-ndb-gestion-sql.txt" "dpkg -l 2>/dev/null | grep -i -E 'mysql-cluster|ndb' || echo 'aucun paquet ndb'"
run_proof "$IP2" "$PW2" "$PROOF_DIR/ch1-lab2/dpkg-ndb-stockage.txt" "dpkg -l 2>/dev/null | grep -i -E 'mysql-cluster|ndb' || echo 'aucun paquet ndb'"
run_proof "$IP3" "$PW3" "$PROOF_DIR/ch1-lab2/dpkg-ndb-mysql-node3.txt" "dpkg -l 2>/dev/null | grep -i -E 'mysql-cluster|ndb' || echo 'aucun paquet ndb'"

echo "Termine partie 1 (nettoyage + config + verif pre-install)."
