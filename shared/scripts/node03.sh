#!/bin/bash
# Node03 initialization: JournalNode, DataNode, and NodeManager setup
set -e

# Configuration
HADOOP_HOME=/opt/hadoop
DATANODE_DIR=/var/hadoop/datanode
JOURNAL_DIR=/var/hadoop/journal

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [node03] $*"
}

# Environment validation
if [[ "$(hostname)" != "node03" ]]; then
    log "Error: This script must be executed on node03."
    exit 1
fi

log "Starting node03 initialization (JournalNode + DataNode + NodeManager)"

# Initialize Local Directories
log "Initializing local directories."
mkdir -p $DATANODE_DIR $JOURNAL_DIR

# Start JournalNode
log "Starting JournalNode..."
if ! jps | grep -q JournalNode; then
    $HADOOP_HOME/bin/hdfs --daemon start journalnode
    sleep 3
fi

# Verify JournalNode Port
if nc -z localhost 8485 2>/dev/null; then
    log "JournalNode is online and listening on port 8485."
else
    log "Warning: JournalNode port 8485 is not responding. Check logs for details."
fi

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
