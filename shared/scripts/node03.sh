#!/bin/bash
# Node03 initialization: JN + DN + NM setup
set -e

echo "[node03] Initializing directories"
mkdir -p /var/hadoop/journal /var/hadoop/datanode

echo "[node03] Starting JournalNode"
hdfs --daemon start journalnode

echo "[node03] Starting DataNode"
hdfs --daemon start datanode

echo "[node03] Starting NodeManager"
yarn --daemon start nodemanager

echo "[node03] Node status:"
jps
