#!/bin/bash
# 03-namenodes-ha.sh — Format & start Active NameNode (dr-node01), bootstrap & start Standby NameNode (dr-node02)
# Service-centric: this script handles ONLY the HDFS NameNode HA layer.

set -e

HADOOP_BIN="/opt/hadoop/bin/hdfs"
NAMENODE_DIR="/var/hadoop/namenode"
CLUSTER_ID="clusterA"

log()  { echo "[$(date '+%H:%M:%S')] [NameNode-HA] $*"; }

# ══════════════════════════════════════════════════════════════════════════════
#  ACTIVE NAMENODE — dr-node01
# ══════════════════════════════════════════════════════════════════════════════
log "── Active NameNode (dr-node01) ──"

# ── Idempotent format: only if VERSION file does not exist ────────────────────
log "Checking if NameNode is already formatted on dr-node01..."
FORMATTED=$(ssh root@dr-node01 "[ -f $NAMENODE_DIR/current/VERSION ] && echo yes || echo no")

if [[ "$FORMATTED" == "no" ]]; then
  log "Formatting NameNode on dr-node01 (clusterId=$CLUSTER_ID)..."
  ssh root@dr-node01 "mkdir -p $NAMENODE_DIR && $HADOOP_BIN namenode -format -clusterId $CLUSTER_ID -force"
  log "NameNode formatted."
else
  log "NameNode already formatted on dr-node01 — skipping."
fi

# ── Format ZKFC ──────────────────────────────────────────────────────────────
log "Formatting ZKFC in ZooKeeper..."
ssh root@dr-node01 "$HADOOP_BIN zkfc -formatZK -force"
log "ZKFC formatted."

# ── Start Active NameNode ────────────────────────────────────────────────────
log "Starting Active NameNode on dr-node01..."
ssh root@dr-node01 "rm -f /tmp/hadoop-root-namenode.pid && $HADOOP_BIN --daemon start namenode"

# ── Wait for safe mode exit ──────────────────────────────────────────────────
log "Waiting for NameNode to exit safe mode..."
for i in $(seq 1 20); do
  ssh root@dr-node01 "$HADOOP_BIN dfsadmin -safemode get 2>/dev/null" | grep -q "OFF" && {
    log "NameNode is out of safe mode."
    break
  }
  log "Still in safe mode... attempt $i/20"
  sleep 5
done

# ── Start ZKFC on dr-node01 ────────────────────────────────────────────────────
log "Starting ZKFC on dr-node01..."
ssh root@dr-node01 "rm -f /tmp/hadoop-root-zkfc.pid && $HADOOP_BIN --daemon start zkfc"
log "ZKFC started on dr-node01."

# ══════════════════════════════════════════════════════════════════════════════
#  STANDBY NAMENODE — dr-node02
# ══════════════════════════════════════════════════════════════════════════════
log "── Standby NameNode (dr-node02) ──"

# ── Idempotent bootstrap: only if VERSION file does not exist ─────────────────
log "Checking if Standby NameNode is already bootstrapped on dr-node02..."
BOOTSTRAPPED=$(ssh root@dr-node02 "[ -f $NAMENODE_DIR/current/VERSION ] && echo yes || echo no")

if [[ "$BOOTSTRAPPED" == "no" ]]; then
  log "Bootstrapping Standby NameNode from Active (dr-node01)..."
  ssh root@dr-node02 "mkdir -p $NAMENODE_DIR && $HADOOP_BIN namenode -bootstrapStandby -force"
  log "Standby NameNode bootstrapped."
else
  log "Standby NameNode already bootstrapped on dr-node02 — skipping."
fi

# ── Start Standby NameNode ───────────────────────────────────────────────────
log "Starting Standby NameNode on dr-node02..."
ssh root@dr-node02 "rm -f /tmp/hadoop-root-namenode.pid && $HADOOP_BIN --daemon start namenode"
sleep 3
log "Standby NameNode started."

# ── Start ZKFC on dr-node02 ────────────────────────────────────────────────────
log "Starting ZKFC on dr-node02..."
ssh root@dr-node02 "rm -f /tmp/hadoop-root-zkfc.pid && $HADOOP_BIN --daemon start zkfc"
log "ZKFC started on dr-node02."

# ── Verify HA state ──────────────────────────────────────────────────────────
sleep 3
log "NameNode HA Status:"
log "  nn1: $($HADOOP_BIN haadmin -getServiceState nn1 2>/dev/null || echo 'not ready yet')"
log "  nn2: $($HADOOP_BIN haadmin -getServiceState nn2 2>/dev/null || echo 'not ready yet')"

log "NameNode HA layer started."
