#!/bin/bash
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
