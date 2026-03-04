#!/bin/bash
<<<<<<< HEAD
# Worker node initialization: DataNode and NodeManager setup
set -e

# Configuration
HADOOP_HOME=/opt/hadoop
DATANODE_DIR=/var/hadoop/datanode
HOSTNAME=$(hostname)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$HOSTNAME] $*"
}

# Environment validation
if [[ "$HOSTNAME" != "node04" && "$HOSTNAME" != "node05" ]]; then
    log "Error: workers.sh is intended for node04 and node05 only."
    exit 1
fi

log "Starting worker initialization (DataNode + NodeManager)"

# Initialize Local Directory
log "Initializing local DataNode directory."
mkdir -p $DATANODE_DIR

# Dependency check: NameNode availability
log "Verifying NameNode availability (node01 or node02)..."
for i in {1..15}; do
    if nc -z node01 8020 2>/dev/null || nc -z node02 8020 2>/dev/null; then
        log "Active NameNode is reachable."
        break
    fi
    log "Waiting for NameNode (attempt $i/15)..."
    sleep 5
    if [[ $i -eq 15 ]]; then
        log "Warning: NameNode not reachable. Starting services (they will retry connection intermittently)."
    fi
done

# Start DataNode
log "Starting DataNode..."
if ! jps | grep -q DataNode; then
    $HADOOP_HOME/bin/hdfs --daemon start datanode
fi

# Start NodeManager
log "Starting NodeManager..."
if ! jps | grep -q NodeManager; then
    $HADOOP_HOME/bin/yarn --daemon start nodemanager
fi

# Final Status
echo "--------------------------------------------"
log "Initialization complete. Current processes:"
jps
echo "--------------------------------------------"
=======

# workers.sh — DataNode + NodeManager for worker nodes (node04, node05)

set -e

# ── Config 
HADOOP_HOME=/opt/hadoop
DATANODE_DIR=/var/hadoop/datanode

# ── Helpers 
HOSTNAME=$(hostname)
log() { echo "[$(date '+%H:%M:%S')] [$HOSTNAME] $*"; }

check_namenode() {
  nc -z node01 8020 2>/dev/null || nc -z node02 8020 2>/dev/null
}

# ── Validate 
if [[ "$HOSTNAME" != "node04" && "$HOSTNAME" != "node05" ]]; then
  echo "ERROR: workers.sh should run on node04 or node05 only"
  exit 1
fi

log "Starting worker node setup (DataNode + NodeManager)"

# ── Create directories 
log "Creating DataNode directory at $DATANODE_DIR"
mkdir -p $DATANODE_DIR

# ── Wait for active NameNode to be reachable 
log "Waiting for an active NameNode to be reachable..."
for i in {1..15}; do
  check_namenode && { log "NameNode is reachable"; break; }
  log "Waiting for NameNode... attempt $i/15"
  sleep 5
  [[ $i -eq 15 ]] && {
    log "NameNode not reachable yet — starting DataNode anyway (it will retry)"
  }
done

# ── Start DataNode 
log "Starting DataNode..."
$HADOOP_HOME/bin/hdfs --daemon start datanode
sleep 2
log "DataNode started"

# ── Start NodeManager 
log "Starting NodeManager..."
$HADOOP_HOME/bin/yarn --daemon start nodemanager
sleep 2
log "NodeManager started"

# ── Summary logging
echo ""
log "============================================"
log "$HOSTNAME services started. Running processes:"
jps
log "============================================"
>>>>>>> origin/cluster-automation
