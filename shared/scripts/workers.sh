#!/bin/bash
# Worker initialization: DN + NM setup
set -e

NODE=$(hostname)
echo "[$NODE] Initializing directory"
mkdir -p /var/hadoop/datanode

echo "[$NODE] Starting DataNode"
hdfs --daemon start datanode

echo "[$NODE] Starting NodeManager"
yarn --daemon start nodemanager

echo "[$NODE] Node status:"
jps
