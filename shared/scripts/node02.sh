#!/bin/bash
# Node02 initialization: Standby NameNode setup
set -e

echo "[node02] Initializing directories"
mkdir -p /var/hadoop/namenode /var/hadoop/journal

echo "[node02] Starting JournalNode"
hdfs --daemon start journalnode
sleep 2

echo "[node02] Bootstrapping Standby NameNode"
hdfs namenode -bootstrapStandby -force

echo "[node02] Starting NameNode"
hdfs --daemon start namenode

echo "[node02] Starting ZKFC"
hdfs --daemon start zkfc

echo "[node02] Node status:"
jps
