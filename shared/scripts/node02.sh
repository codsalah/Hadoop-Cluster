#!/bin/bash
# Node02 initialization: Standby NameNode, ZKFC, and ResourceManager setup
set -e

# Configuration
HADOOP_HOME=/opt/hadoop
NAMENODE_DIR=/var/hadoop/namenode
JOURNAL_DIR=/var/hadoop/journal

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
