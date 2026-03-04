Host Prerequisites Check 

```bash
$ docker --version
$ docker compose version
$ df -h .
$ systemctl is-active docker

```

Configuration File Validation 

```bash
$ ls config/hadoop/
$ ls config/zookeeper/
$ xmllint --noout config/hadoop/core-site.xml && echo OK
$ xmllint --noout config/hadoop/hdfs-site.xml && echo OK
$ xmllint --noout config/hadoop/yarn-site.xml && echo OK
$ xmllint --noout config/hadoop/mapred-site.xml && echo OK

```

Launch Command 

```bash
$ cd /home/codsalah/Documents/git_repos/Hadoop-Cluster
$ docker compose up -d

```

Container Status Verification 

```bash
$ docker compose ps

```

ZooKeeper Service Startup Logs (node01) 

```bash
$ docker exec node01 cat /opt/zookeeper/logs/zookeeper--server-node01.out

```

Verify Quorum Status 

```bash
$ docker exec node01 /opt/zookeeper/bin/zkServer.sh status
$ docker exec node02 /opt/zookeeper/bin/zkServer.sh status
$ docker exec node03 /opt/zookeeper/bin/zkServer.sh status

```

Verify ZooKeeper Processes (jps) 

```bash
$ docker exec node01 jps | grep QuorumPeer
$ docker exec node02 jps | grep QuorumPeer
$ docker exec node03 jps | grep QuorumPeer

```

JournalNode Startup (All Three Nodes) 

```bash
$ docker exec node01 hdfs journalnode &
$ docker exec node02 hdfs journalnode &
$ docker exec node03 hdfs journalnode &
$ for n in node01 node02 node03; do echo -n "$n: "; docker exec $n jps | grep JournalNode; done

```

JournalNode HTTP Verification 

```bash
$ curl -s -o /dev/null -w "%{http_code}" http://localhost:8481/
$ curl -s -o /dev/null -w "%{http_code}" http://localhost:8482/
$ curl -s -o /dev/null -w "%{http_code}" http://localhost:8483/

```

JournalNode Storage Directory 

```bash
$ docker exec node01 ls /var/hadoop/journal/clusterA/
$ docker exec node01 ls /var/hadoop/journal/clusterA/current/

```

ZooKeeper Failover Controller (ZKFC) Initialization 

```bash
$ docker exec node01 hdfs zkfc -formatZK

```

NameNode Format (First Boot Only) 

```bash
$ docker exec node01 hdfs namenode -format -clusterId clusterA

```

Standby NameNode Bootstrap (node02) 

```bash
$ docker exec node02 hdfs namenode -bootstrapStandby

```

Start NameNodes and ZKFC 

```bash
$ docker exec node01 hdfs --daemon start namenode
$ docker exec node02 hdfs --daemon start namenode
$ docker exec node01 hdfs --daemon start zkfc
$ docker exec node02 hdfs --daemon start zkfc

```

Verify NameNode Status 

```bash
$ hdfs haadmin -getServiceState nn1
$ hdfs haadmin -getServiceState nn2
$ docker exec node01 jps
$ docker exec node02 jps

```

DataNode Start Commands 

```bash
$ docker exec node03 hdfs --daemon start datanode
$ docker exec node04 hdfs --daemon start datanode
$ docker exec node05 hdfs --daemon start datanode

```

DataNode Registration Log (node03) 

```bash
$ docker exec node03 tail -30 /opt/hadoop/logs/hadoop-*-datanode-node03.log

```

HDFS Cluster Report 

```bash
$ docker exec node01 hdfs dfsadmin -report

```

Safemode Check and Exit 

```bash
$ docker exec node01 hdfs dfsadmin -safemode get
# If Safemode is ON but not all DataNodes have registered yet, keep polling:
$ docker exec node01 hdfs dfsadmin -report
# Once the expected number of Live datanodes is visible, explicitly leave Safemode:
$ docker exec node01 hdfs dfsadmin -safemode leave
$ docker exec node01 hdfs dfsadmin -report

```

Note: If DataNode registration is delayed, continue polling `hdfs dfsadmin -report` until all expected DataNodes appear before leaving Safemode to avoid under-replicated or missing blocks.

Start ResourceManagers 

```bash
$ docker exec node01 yarn --daemon start resourcemanager
$ docker exec node02 yarn --daemon start resourcemanager

```

Start NodeManagers 

```bash
$ docker exec node03 yarn --daemon start nodemanager
$ docker exec node04 yarn --daemon start nodemanager
$ docker exec node05 yarn --daemon start nodemanager

```

ResourceManager HA State Check 

```bash
$ docker exec node01 yarn rmadmin -getServiceState rm1
$ docker exec node01 yarn rmadmin -getServiceState rm2

```

YARN Cluster Report 

```bash
$ docker exec node01 yarn node -list

```

Full Process List (node01 — Active Hub) 

```bash
$ docker exec node01 jps

```

Initial HDFS Directory Structure 

```bash
$ docker exec node01 hdfs dfs -ls /
$ docker exec node01 hdfs dfs -mkdir -p /user/root
$ docker exec node01 hdfs dfs -mkdir -p /tmp
$ docker exec node01 hdfs dfs -mkdir -p /user/hadoop/input
$ docker exec node01 hdfs dfs -chmod 1777 /tmp
$ docker exec node01 hdfs dfs -ls /

```

NameNode Metadata Structure 

```bash
$ docker exec node01 ls -la /var/hadoop/namenode/current/

```

NameNode VERSION File 

```bash
$ docker exec node01 cat /var/hadoop/namenode/current/VERSION

```

HDFS Fsck — Filesystem Health 

```bash
$ docker exec node01 hdfs fsck /

```

Prepare Input Data 

```bash
$ echo "hadoop hdfs yarn mapreduce hadoop cluster node" > /shared/wordcount_input.txt
$ docker exec node01 hdfs dfs -put /shared/wordcount_input.txt /user/hadoop/input/
$ docker exec node01 hdfs dfs -ls /user/hadoop/input/

```

Submit MapReduce Job 

```bash
$ docker exec node01 hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar wordcount /user/hadoop/input /user/hadoop/output

```

Verify Output 

```bash
$ docker exec node01 hdfs dfs -cat /user/hadoop/output/part-r-00000

```

Pre-Failover State 

```bash
$ docker exec node01 hdfs haadmin -getServiceState nn1
$ docker exec node01 hdfs haadmin -getServiceState nn2

```

Simulate Active NameNode Failure 

```bash
$ docker exec node01 kill -9 $(docker exec node01 jps | grep NameNode | awk '{print $1}')
$ docker exec node02 tail -20 /opt/hadoop/logs/hadoop-*-zkfc-node02.log

```

Post-Failover State 

```bash
$ docker exec node02 hdfs haadmin -getServiceState nn2
$ docker exec node02 hdfs dfsadmin -report | grep 'Live datanodes'

```

YARN ResourceManager Failover Test 

```bash
$ docker exec node01 kill -9 $(docker exec node01 jps | grep ResourceManager | awk '{print $1}')
$ docker exec node02 yarn rmadmin -getServiceState rm2
$ docker exec node02 yarn node -list

```

Log Tail Commands for Debugging 

```bash
$ docker exec node01 tail -f /opt/hadoop/logs/hadoop-*-namenode-node01.log
$ docker exec node01 tail -100 /opt/hadoop/logs/yarn-*-resourcemanager-node01.log | grep ERROR
$ docker exec node03 tail -50 /opt/hadoop/logs/hadoop-*-datanode-node03.log
$ for n in node01 node02 node03 node04 node05; do echo "=== $n ==="; docker exec $n grep -rh 'ERROR\|FATAL' /opt/hadoop/logs/ 2>/dev/null | tail -5; done

```

Final HDFS State 

```bash
$ docker exec node01 hdfs dfs -ls -R /

```

Cluster Health Quick Reference 

```bash
$ docker exec node01 bash -c 'echo "=== ZK ==="; /opt/zookeeper/bin/zkServer.sh status 2>/dev/null | grep Mode; echo "=== HDFS HA ==="; hdfs haadmin -getAllServiceState; echo "=== YARN HA ==="; yarn rmadmin -getAllServiceStates; echo "=== DataNodes ==="; hdfs dfsadmin -report | grep "^Name:"; echo "=== YARN Nodes ==="; yarn node -list 2>/dev/null | grep RUNNING'

```

Shutdown Procedure 

```bash
$ docker compose down
$ docker compose down -v
$ docker compose down -v --rmi all

```

