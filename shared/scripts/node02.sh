#!/bin/bash
<<<<<<< HEAD
# Node02 initialization: Standby NameNode, ZKFC, and ResourceManager setup
set -e

# Configuration
=======

# node02.sh — Standby NameNode + ZKFC + ResourceManager (Standby), Should only run on node02, AFTER:
#   1. node01.sh ran successfully on node01 (Active NN + ZKFC + RM Active)
#   2. zk-init.sh ran on node01/02/03 (ZooKeeper quorum is up)

set -e

# ── Config ────────────────────────────────────────────────────────────────────
>>>>>>> origin/cluster-automation
HADOOP_HOME=/opt/hadoop
NAMENODE_DIR=/var/hadoop/namenode
JOURNAL_DIR=/var/hadoop/journal

<<<<<<< HEAD
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [node02] $*"
}

# Environment validation
if [[ "$(hostname)" != "node02" ]]; then
    log "Error: This script must be executed on node02."
    exit 1
fi

log "Starting node02 initialization (Standby NameNode + ZKFC + ResourceManager)"

# Dependency check: Active NameNode on node01
log "Verifying Active NameNode availability on node01..."
for i in {1..15}; do
    if nc -z node01 8020 2>/dev/null; then
        log "Active NameNode is reachable."
        break
    fi
    log "Waiting for Active NameNode (attempt $i/15)..."
    sleep 5
    if [[ $i -eq 15 ]]; then
        log "Error: Active NameNode not reachable. Please ensure node01.sh has been executed."
        exit 1
    fi
done

# Initialize Local Directories
log "Initializing local directories."
mkdir -p $JOURNAL_DIR $NAMENODE_DIR

# Start JournalNode
log "Starting JournalNode..."
if ! jps | grep -q JournalNode; then
    $HADOOP_HOME/bin/hdfs --daemon start journalnode
    sleep 3
fi

# Bootstrap Standby NameNode
if [[ ! -d "$NAMENODE_DIR/current" ]]; then
    log "Bootstrapping Standby NameNode from Active NameNode..."
    $HADOOP_HOME/bin/hdfs namenode -bootstrapStandby -force
else
    log "Standby NameNode already bootstrapped. Skipping."
fi

# Start Services
log "Starting Standby NameNode..."
if ! jps | grep -q NameNode; then
    $HADOOP_HOME/bin/hdfs --daemon start namenode
fi

log "Starting ZKFC..."
if ! jps | grep -q DFSZKFailoverController; then
    $HADOOP_HOME/bin/hdfs --daemon start zkfc
fi

log "Starting ResourceManager (Standby)..."
if ! jps | grep -q ResourceManager; then
    $HADOOP_HOME/bin/yarn --daemon start resourcemanager
fi

# Final Status
echo "--------------------------------------------"
log "Initialization complete. Current processes:"
jps
echo "--------------------------------------------"
log "HA Service States:"
$HADOOP_HOME/bin/hdfs haadmin -getServiceState nn2 2>/dev/null || log "haadmin status unavailable"
$HADOOP_HOME/bin/yarn rmadmin -getServiceState rm2 2>/dev/null || log "rmadmin status unavailable"
echo "--------------------------------------------"
=======
# ── Helpers ───────────────────────────────────────────────────────────────────
log() { echo "[$(date '+%H:%M:%S')] [node02] $*"; }

check_active_nn() {
  # Check if node01's NameNode RPC port is open
  nc -z node01 8020 2>/dev/null
}

# ── Validate ──────────────────────────────────────────────────────────────────
if [[ "$(hostname)" != "node02" ]]; then
  echo "ERROR: This script must run on node02 only"
  exit 1
fi

log "Starting node02 setup (Standby NameNode + ZKFC + ResourceManager)"

# ── Wait for Active NameNode on node01 ───────────────────────────────────────
log "Waiting for Active NameNode on node01:8020..."
for i in {1..15}; do
  check_active_nn && { log "Active NameNode is reachable"; break; }
  log "Waiting... attempt $i/15"
  sleep 5
  [[ $i -eq 15 ]] && { log "Active NameNode not reachable. Run node01.sh first."; exit 1; }
done

# ── Start JournalNode on node02 ───────────────────────────────────────────────
# log "Creating JournalNode directory"
# mkdir -p $JOURNAL_DIR
# log "Starting JournalNode..."
# $HADOOP_HOME/bin/hdfs --daemon start journalnode
# sleep 3
# log "JournalNode started"

# ── Bootstrap Standby NameNode ────────────────────────────────────────────────
mkdir -p $NAMENODE_DIR

if [[ ! -f $NAMENODE_DIR/current/VERSION ]]; then
  log "Bootstrapping Standby NameNode from Active (node01)..."
  log "This copies NameNode metadata so both NNs have identical state"
  $HADOOP_HOME/bin/hdfs namenode -bootstrapStandby -force
  log "Standby NameNode bootstrapped successfully"
else
  log "Standby NameNode already bootstrapped — skipping"
fi

# ── Start Standby NameNode ────────────────────────────────────────────────────
log "Starting Standby NameNode..."
$HADOOP_HOME/bin/hdfs --daemon start namenode
sleep 3
log "Standby NameNode started"

# ── Start ZKFC ────────────────────────────────────────────────────────────────
log "Starting ZooKeeper Failover Controller..."
$HADOOP_HOME/bin/hdfs --daemon start zkfc
log "ZKFC started"

# ── Start ResourceManager (Standby) ──────────────────────────────────────────
log "Starting ResourceManager (Standby)..."
$HADOOP_HOME/bin/yarn --daemon start resourcemanager
log "ResourceManager started"

# ── Summary ───────────────────────────────────────────────────────────────────
# echo ""
# log "============================================"
# log "node02 services started. Running processes:"
# jps
# log "============================================"
# log "NameNode HA state:"
# $HADOOP_HOME/bin/hdfs haadmin -getServiceState nn2 2>/dev/null || log "(haadmin not ready yet)"
# log "YARN RM HA state:"
# $HADOOP_HOME/bin/yarn rmadmin -getServiceState rm2 2>/dev/null || log "(rmadmin not ready yet)"
>>>>>>> origin/cluster-automation
