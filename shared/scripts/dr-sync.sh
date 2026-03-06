#!/bin/bash
echo "Starting Disaster Recovery Synchronization..."

PRIMARY_TAILSCALE_IP="100.75.183.48"

# 1. Hunt for the Active Primary (Source) NameNode
if hdfs dfs -ls hdfs://node01:8020/ > /dev/null 2>&1; then
    PRIMARY_NN="node01"
elif hdfs dfs -ls hdfs://node02:8020/ > /dev/null 2>&1; then
    PRIMARY_NN="node02"
else
    echo "CRITICAL ERROR: No Active NameNode found on the Primary Cluster!"
    exit 1
fi

# 2. Hunt for the Active DR (Target) NameNode
if hdfs dfs -ls hdfs://dr-node01:8020/ > /dev/null 2>&1; then
    DR_NN="dr-node01"
elif hdfs dfs -ls hdfs://dr-node02:8020/ > /dev/null 2>&1; then
    DR_NN="dr-node02"
else
    echo "CRITICAL ERROR: No Active NameNode found on the DR Vault!"
    exit 1
fi

echo "Active Primary found at: $PRIMARY_NN"
echo "Active DR Vault found at: $DR_NN"
echo "Initiating DistCp MapReduce job..."

# 3. Execute DistCp dynamically
/opt/hadoop/bin/hadoop distcp -Ddfs.client.use.datanode.hostname=true -update -pt hdfs://${PRIMARY_NN}:8020/ hdfs://${DR_NN}:8020/

# 4. Rsync (OS-Level Metadata Backup)
echo "[$(date '+%H:%M:%S')] Initiating Rsync for NameNode Metadata..."
mkdir -p /shared/dr-backups/namenode/

# Your working Rsync command, now 100% dynamic
rsync -avz -e "ssh -i /shared/dr_rsa_key -o StrictHostKeyChecking=no" --rsync-path="docker exec -i $PRIMARY_NN rsync" root@${PRIMARY_TAILSCALE_IP}:/var/hadoop/namenode/ /shared/dr-backups/namenode/

echo "Disaster Recovery Synchronization Complete."