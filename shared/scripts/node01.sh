#!/bin/bash
# Node01 initialization: Active NameNode, ZKFC, and ResourceManager setup
set -e

# Configuration
HADOOP_HOME=/opt/hadoop
NAMENODE_DIR=/var/hadoop/namenode
JOURNAL_DIR=/var/hadoop/journal
CLUSTER_ID=clusterA

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [node01] $*"
}

# Environment validation
if [[ "$(hostname)" != "node01" ]]; then
    log "Error: This script must be executed on node01."
    exit 1
fi

log "Starting node01 initialization (Active NameNode + ZKFC + ResourceManager)"

# Dependency check: ZooKeeper Quorum
log "Verifying ZooKeeper availability..."
for i in {1..10}; do
    if echo ruok | nc node01 2181 2>/dev/null | grep -q imok; then
        log "ZooKeeper is online."
        break
    fi
    log "Waiting for ZooKeeper (attempt $i/10)..."
    sleep 5
    if [[ $i -eq 10 ]]; then
        log "Error: ZooKeeper quorum not reachable."
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

# NameNode Formatting
if [[ ! -d "$NAMENODE_DIR/current" ]]; then
    log "Formatting NameNode with Cluster ID: $CLUSTER_ID"
    $HADOOP_HOME/bin/hdfs namenode -format -clusterId $CLUSTER_ID -force
else
    log "NameNode already formatted. Skipping."
fi

# ZKFC Initialization
log "Initializing ZooKeeper Failover Controller (ZKFC)..."
$HADOOP_HOME/bin/hdfs zkfc -formatZK -force || true

# Start NameNode
log "Starting NameNode..."
if ! jps | grep -q NameNode; then
    $HADOOP_HOME/bin/hdfs --daemon start namenode
fi

# Wait for NameNode to exit Safe Mode
log "Waiting for NameNode to exit Safe Mode..."
for i in {1..20}; do
    if $HADOOP_HOME/bin/hdfs dfsadmin -safemode get 2>/dev/null | grep -q "OFF"; then
        log "NameNode is out of SAFE MODE."
        break
    fi
    log "NameNode still in SAFE MODE (attempt $i/20)..."
    sleep 5
done

# Start Support Services
log "Starting ZKFC..."
if ! jps | grep -q DFSZKFailoverController; then
    $HADOOP_HOME/bin/hdfs --daemon start zkfc
fi

log "Starting ResourceManager..."
if ! jps | grep -q ResourceManager; then
    $HADOOP_HOME/bin/yarn --daemon start resourcemanager
fi

# Final Status
echo "--------------------------------------------"
log "Initialization complete. Current processes:"
jps
echo "--------------------------------------------"
log "HA Service States:"
$HADOOP_HOME/bin/hdfs haadmin -getServiceState nn1 2>/dev/null || log "haadmin status unavailable"
$HADOOP_HOME/bin/yarn rmadmin -getServiceState rm1 2>/dev/null || log "rmadmin status unavailable"
echo "--------------------------------------------"
