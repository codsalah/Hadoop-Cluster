# Hadoop HA — Node Command History

## node01 — PRIMARY NameNode (Active)
> Services: **NameNode · ZKFC · ResourceManager · JournalNode · ZooKeeper**

| # | Command | Purpose |
|---|---------|---------|
| 1 | `jps` | Check running JVM processes |
| 2 | `tail -n 50 $HADOOP_HOME/logs/*-namenode-*.log` | View last 50 lines of NameNode log |
| 3 | `clear` | Clear terminal |
| 4 | `hdfs dfsadmin -report` | Full HDFS cluster report |
| 5 | `hdfs dfs -ls /` | List root HDFS directory |
| 6 | `hdfs haadmin -getServiceState nn1` | Check HA state of NameNode nn1 |
| 7 | `hdfs haadmin -getServiceState nn2` | Check HA state of NameNode nn2 |
| 8 | `clear` | Clear terminal |
| 9 | `jps` | Check running JVM processes |
| 10 | `zkServer.sh status` | Check ZooKeeper server status |
| 11 | `clear` | Clear terminal |
| 12 | `exit` | Exit shell |
| 13 | `hdfs haadmin -getServiceState nn1` | Check HA state of NameNode nn1 |
| 14 | `hdfs haadmin -getServiceState nn2` | Check HA state of NameNode nn2 |
| 15 | `yarn rmadmin -getServiceState rm1` | Check HA state of ResourceManager rm1 |
| 16 | `yarn rmadmin -getServiceState rm2` | Check HA state of ResourceManager rm2 |
| 17 | `hdfs dfsadmin -report` | Full HDFS cluster report |
| 18 | `yarn node -list -all` | List all YARN nodes |
| 19 | `echo ruok \| nc localhost 2181` | Send ZooKeeper "ruok" health check |
| 20 | `exit` | Exit shell |
| 21 | `history` | Show command history |
| 22 | `tail -n 50 $HADOOP_HOME/logs/*-namenode-*.log` | View last 50 lines of NameNode log |
| 23 | `clear` | Clear terminal |
| 24 | `hdfs dfsadmin -safemode get` | Check HDFS safe mode status |
| 25 | `$HADOOP_HOME/bin/hdfs --daemon start journalnode` | Start JournalNode daemon |
| 26 | `$HADOOP_HOME/bin/hdfs --daemon start zkfc` | Start ZooKeeper Failover Controller |
| 27 | `exit` | Exit shell |
| 28 | `yarn application -list -appStates RUNNING` | List currently running YARN apps |
| 29 | `tail -f $HADOOP_HOME/logs/*-resourcemanager-*.log \| grep -i "wordcount\|application"` | Monitor ResourceManager log for WordCount job |
| 30 | `hdfs dfs -ls /user/hadoop/wordcount/output/` | List WordCount output in HDFS |
| 31 | `hdfs dfs -cat /user/hadoop/wordcount/output/part-r-00000` | View WordCount results |
| 32 | `yarn application -list -appStates FINISHED` | List finished YARN applications |
| 33 | `history` | Show command history |
| 34 | `yarn queue -status default` | Check status of default YARN queue |
| 35 | `yarn node -status node03:8042` | Check status of node03 NodeManager |
| 36 | `yarn node -status node04:8042` | Check status of node04 NodeManager |
| 37 | `yarn node -list -all` | List all YARN nodes |
| 38 | `hdfs dfsadmin -saveNamespace` | Force checkpoint / save NameNode metadata |
| 39 | `clear` | Clear terminal |
| 40 | `history` | Show command history |
| 41 | `$HADOOP_HOME/bin/hdfs --daemon start namenode` | Start NameNode daemon |
| 42 | `$HADOOP_HOME/bin/yarn --daemon start resourcemanager` | Start ResourceManager daemon |
| 43 | `hdfs dfsadmin -metasave metareport.txt` | Dump NameNode metadata to file |
| 44 | `cat metareport.txt \| head -50` | Preview NameNode metadata report |
| 45 | `hdfs dfsadmin -printTopology` | Print cluster rack topology |
| 46 | `hdfs dfsadmin -listOpenFiles` | List all files currently open in HDFS |
| 47 | `hdfs haadmin -failover nn1 nn2` | Manually trigger failover from nn1 to nn2 |
| 48 | `hdfs haadmin -transitionToActive nn1` | Manually transition nn1 back to Active |
| 49 | `yarn rmadmin -refreshNodes` | Refresh ResourceManager node list |
| 50 | `yarn rmadmin -refreshQueues` | Reload YARN queue configuration |
| 51 | `grep -i "ERROR\|FATAL" $HADOOP_HOME/logs/*-namenode-*.log \| tail -30` | Filter critical NameNode errors |
| 52 | `grep -i "standby\|active\|failover" $HADOOP_HOME/logs/*-zkfc-*.log \| tail -20` | Monitor ZKFC failover events |
| 53 | `tail -f $HADOOP_HOME/logs/*-zkfc-*.log` | Stream ZKFC logs live |
| 54 | `tail -f $HADOOP_HOME/logs/*-journalnode-*.log` | Stream JournalNode logs live |
| 55 | `echo stat \| nc localhost 2181` | Get ZooKeeper server stats |
| 56 | `echo mntr \| nc localhost 2181` | Get detailed ZooKeeper monitoring metrics |
| 57 | `$ZOOKEEPER_HOME/bin/zkCli.sh -server localhost:2181` | Open ZooKeeper CLI shell |
| 58 | `hdfs dfs -count -q /user/` | Show quota usage for /user/ |
| 59 | `hdfs dfsadmin -setSpaceQuota 100g /user/hadoop` | Set 100GB space quota on hadoop user dir |
| 60 | `hdfs dfs -checksum /user/hadoop/wordcount/input/test1.txt` | Verify file checksum in HDFS |
| 61 | `yarn logs -applicationId <app_id>` | Retrieve logs for a specific YARN application |
| 62 | `hdfs dfsadmin -refreshNodes` | Refresh DataNode registration list |
| 63 | `hdfs dfsadmin -report \| grep -E "Live datanodes\|Dead datanodes\|Decommissioning"` | Summary of DataNode health |

---

## node02 — SECONDARY HA NameNode (Standby)
> Services: **NameNode · ZKFC · ResourceManager · JournalNode · ZooKeeper**

| # | Command | Purpose |
|---|---------|---------|
| 1 | `jps` | Check running JVM processes |
| 2 | `hdfs haadmin -getServiceState nn2` | Confirm this node is in Standby state |
| 3 | `hdfs haadmin -getServiceState nn1` | Check Active node's HA state |
| 4 | `yarn rmadmin -getServiceState rm2` | Check ResourceManager HA state on this node |
| 5 | `zkServer.sh status` | Check ZooKeeper server status |
| 6 | `echo ruok \| nc localhost 2181` | Send ZooKeeper "ruok" health check |
| 7 | `clear` | Clear terminal |
| 8 | `$HADOOP_HOME/bin/hdfs --daemon start namenode` | Start NameNode daemon (Standby) |
| 9 | `$HADOOP_HOME/bin/hdfs --daemon start zkfc` | Start ZKFC on this node |
| 10 | `$HADOOP_HOME/bin/hdfs --daemon start journalnode` | Start JournalNode daemon |
| 11 | `$HADOOP_HOME/bin/yarn --daemon start resourcemanager` | Start Standby ResourceManager |
| 12 | `$ZOOKEEPER_HOME/bin/zkServer.sh start` | Start ZooKeeper on this node |
| 13 | `tail -n 50 $HADOOP_HOME/logs/*-namenode-*.log` | View last 50 lines of NameNode log |
| 14 | `grep -i "standby\|active\|checkpoint" $HADOOP_HOME/logs/*-namenode-*.log \| tail -30` | Monitor standby/checkpoint transitions |
| 15 | `tail -f $HADOOP_HOME/logs/*-zkfc-*.log` | Stream ZKFC logs live |
| 16 | `grep -i "ERROR\|FATAL" $HADOOP_HOME/logs/*-namenode-*.log \| tail -30` | Filter critical NameNode errors |
| 17 | `tail -f $HADOOP_HOME/logs/*-journalnode-*.log` | Stream JournalNode logs live |
| 18 | `grep -i "ERROR\|sync\|epoch" $HADOOP_HOME/logs/*-journalnode-*.log \| tail -30` | Check JournalNode sync/epoch/errors |
| 19 | `hdfs dfsadmin -safemode get` | Check HDFS safe mode status |
| 20 | `hdfs dfsadmin -report` | Full HDFS cluster report |
| 21 | `hdfs dfs -ls /` | List root HDFS directory |
| 22 | `yarn node -list -all` | List all YARN nodes |
| 23 | `yarn rmadmin -refreshQueues` | Reload YARN queue configuration |
| 24 | `yarn rmadmin -refreshNodes` | Refresh ResourceManager node list |
| 25 | `echo stat \| nc localhost 2181` | Get ZooKeeper server stats |
| 26 | `echo mntr \| nc localhost 2181` | Get detailed ZooKeeper monitoring metrics |
| 27 | `$ZOOKEEPER_HOME/bin/zkCli.sh -server localhost:2181` | Open ZooKeeper CLI to inspect /hadoop-ha znode |
| 28 | `hdfs namenode -bootstrapStandby` | Bootstrap Standby NameNode from Active |
| 29 | `hdfs namenode -initializeSharedEdits` | Initialize shared edits directory (JournalNodes) |
| 30 | `grep -i "standby\|active\|failover" $HADOOP_HOME/logs/*-zkfc-*.log \| tail -20` | Monitor ZKFC failover events |
| 31 | `tail -f $HADOOP_HOME/logs/*-resourcemanager-*.log` | Stream ResourceManager logs live |
| 32 | `grep -i "ERROR\|FATAL" $HADOOP_HOME/logs/*-resourcemanager-*.log \| tail -30` | Filter critical ResourceManager errors |
| 33 | `yarn application -list -appStates RUNNING` | List currently running YARN apps (via Standby RM) |
| 34 | `hdfs dfsadmin -printTopology` | Print cluster rack topology |
| 35 | `df -h /` | Check disk usage of root filesystem |
| 36 | `df -h /hadoop/` | Check disk usage of Hadoop directories |
| 37 | `free -h` | Check available memory |
| 38 | `top -bn1 \| head -20` | Snapshot of CPU/memory usage |
| 39 | `netstat -tlnp \| grep -E "8020\|8022\|8480\|2181\|2888\|3888"` | Verify Hadoop/ZooKeeper ports are listening |
| 40 | `history` | Show command history |

---

## node03 — Worker (DataNode · NodeManager · JournalNode · ZooKeeper)
> Services: **DataNode · NodeManager · JournalNode · ZooKeeper**

| # | Command | Purpose |
|---|---------|---------|
| 1 | `history` | Show command history |
| 2 | `$HADOOP_HOME/bin/yarn --daemon start nodemanager` | Start NodeManager daemon |
| 3 | `jps` | Check running JVM processes |
| 4 | `$ZOOKEEPER_HOME/bin/zkServer.sh status` | Check ZooKeeper server status |
| 5 | `hdfs dfs -ls /` | List root HDFS directory |
| 6 | `hdfs dfs -du -s -h /user/` | Summarize disk usage of /user/ |
| 7 | `hdfs dfs -du -s -h /` | Summarize disk usage of HDFS root |
| 8 | `tail -f $HADOOP_HOME/logs/*-datanode-*.log` | Stream DataNode logs live |
| 9 | `cat -f $HADOOP_HOME/logs/*-datanode-*.log` | *(Attempted)* Stream DataNode logs |
| 10 | `cat $HADOOP_HOME/logs/*-datanode-*.log` | Print full DataNode log |
| 11 | `clear` | Clear terminal |
| 12 | `cat $HADOOP_HOME/logs/*-datanode-*.log \| grep fail` | Filter DataNode log for failures |
| 13 | `clear` | Clear terminal |
| 14 | `grep "disk" $HADOOP_HOME/logs/*-datanode-*.log \| tail -20` | Check for disk-related log entries |
| 15 | `grep -i "ERROR\|FAILED\|lost" $HADOOP_HOME/logs/*-datanode-*.log \| tail -30` | Filter errors/failures in DataNode log (30 lines) |
| 16 | `grep -i "ERROR\|FAILED\|lost" $HADOOP_HOME/logs/*-datanode-*.log \| tail -70` | Filter errors/failures in DataNode log (70 lines) |
| 17 | `tail -f $HADOOP_HOME/logs/*-journalnode-*.log` | Stream JournalNode logs live |
| 18 | `clear` | Clear terminal |
| 19 | `history` | Show command history |
| 20 | `grep -i "ERROR\|sync\|epoch" $HADOOP_HOME/logs/*-journalnode-*.log \| tail -30` | Check JournalNode sync/epoch/errors |
| 21 | `clear` | Clear terminal |
| 22 | `history` | Show command history |
| 23 | `hdf dfsadmin -report` | *(Typo)* Attempted HDFS admin report |
| 24 | `hdfs dfsadmin -report` | Full HDFS cluster report |
| 25 | `hdfs dfsadmin -report \| grep -E` | *(Incomplete)* Attempted grep filter on report |
| 26 | `hdfs dfsadmin -report \| grep -E "Live datanodes\|Dead datanodes"` | Count live vs dead DataNodes |
| 27 | `hdfs dfsadmin -safemode get` | Check HDFS safe mode status |
| 28 | `yarn node -list -all` | List all YARN nodes |
| 29 | `hdfs dfs -mkdir -p /user/hadoop/wordcount/input` | Create WordCount input directory |
| 30 | `echo "hello world hello hadoop hello mapreduce world hadoop" > /tmp/test1.txt` | Create first test input file |
| 31 | `echo "hadoop is great hadoop runs on clusters" > /tmp/test2.txt` | Create second test input file |
| 32 | `hdfs dfs -put /tmp/test1.txt /user/hadoop/wordcount/input/` | Upload test1 to HDFS |
| 33 | `hdfs dfs -put /tmp/test2.txt /user/hadoop/wordcount/input/` | Upload test2 to HDFS |
| 34 | `hdfs dfs -ls /user/hadoop/wordcount/input/` | Verify input files in HDFS |
| 35 | `hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar wordcount /user/hadoop/wordcount/input /user/hadoop/wordcount/output` | Run WordCount MapReduce job |
| 36 | `clear` | Clear terminal |
| 37 | `history` | Show command history |
| 38 | `$HADOOP_HOME/bin/hdfs --daemon start datanode` | Start DataNode daemon |
| 39 | `$HADOOP_HOME/bin/hdfs --daemon start journalnode` | Start JournalNode daemon |
| 40 | `$ZOOKEEPER_HOME/bin/zkServer.sh start` | Start ZooKeeper on this node |
| 41 | `df -h /hadoop/data/` | Check disk usage of Hadoop data directory |
| 42 | `df -h /` | Check disk usage of root filesystem |
| 43 | `iostat -xz 1 5` | Monitor disk I/O statistics (5 samples) |
| 44 | `du -sh /hadoop/data/*` | Summarize size of each Hadoop data subdirectory |
| 45 | `echo stat \| nc localhost 2181` | Get ZooKeeper server stats |
| 46 | `echo mntr \| nc localhost 2181` | Get detailed ZooKeeper monitoring metrics |
| 47 | `echo ruok \| nc localhost 2181` | Send ZooKeeper "ruok" health check |
| 48 | `grep -i "container\|launch\|ERROR" $HADOOP_HOME/logs/*-nodemanager-*.log \| tail -30` | Filter NodeManager container/launch errors |
| 49 | `tail -f $HADOOP_HOME/logs/*-nodemanager-*.log` | Stream NodeManager logs live |
| 50 | `hdfs dfsadmin -getDatanodeInfo node03:9866` | Get detailed info for this DataNode |
| 51 | `netstat -tlnp \| grep -E "9864\|9866\|8042\|8480\|2181"` | Verify DataNode/NodeManager/ZK ports |
| 52 | `free -h` | Check available memory |
| 53 | `vmstat 1 5` | Monitor system performance (5 samples) |

---

## node04 — Worker (DataNode · NodeManager)
> Services: **DataNode · NodeManager**

| # | Command | Purpose |
|---|---------|---------|
| 1 | `clear` | Clear terminal |
| 2 | `history` | Show command history |
| 3 | `jps` | Check running JVM processes |
| 4 | `$HADOOP_HOME/bin/hdfs --daemon start datanode` | Start DataNode daemon |
| 5 | `$HADOOP_HOME/bin/hdfs --daemon start journalnode` | *(Unnecessary on node04)* Attempted JournalNode start |
| 6 | `$HADOOP_HOME/bin/yarn --daemon start nodemanager` | Start NodeManager daemon |
| 7 | `hdfs dfs -ls /` | List root HDFS directory |
| 8 | `hdfs dfs -ls -R /user/` | Recursively list /user/ in HDFS |
| 9 | `tail -f $HADOOP_HOME/logs/*-datanode-*.log` | Stream DataNode logs live |
| 10 | `clear` | Clear terminal |
| 11 | `tail -f $HADOOP_HOME/logs/*-nodemanager-*.log` | Stream NodeManager logs live |
| 12 | `grep -i "ERROR\|container\|launch" $HADOOP_HOME/logs/*-nodemanager-*.log \| tail -30` | Filter NodeManager container/launch errors |
| 13 | `jps` | Check running JVM processes |
| 14 | `tail -f $ZOOKEEPER_HOME/logs/zookeeper-*.log` | *(ZK not on node04)* Attempted ZooKeeper log stream |
| 15 | `df -h /hadoop/data/` | Check disk usage of Hadoop data directory |
| 16 | `clear` | Clear terminal |
| 17 | `df -h /` | Check disk usage of root filesystem |
| 18 | `history` | Show command history |
| 19 | `grep -i "ERROR\|FAILED\|lost" $HADOOP_HOME/logs/*-datanode-*.log \| tail -30` | Filter errors in DataNode log |
| 20 | `grep "disk\|volume" $HADOOP_HOME/logs/*-datanode-*.log \| tail -20` | Check for disk/volume issues in DataNode log |
| 21 | `du -sh /hadoop/data/*` | Summarize size of each data subdirectory |
| 22 | `iostat -xz 1 5` | Monitor disk I/O statistics (5 samples) |
| 23 | `free -h` | Check available memory |
| 24 | `top -bn1 \| head -20` | Snapshot of CPU/memory usage |
| 25 | `netstat -tlnp \| grep -E "9864\|9866\|8042"` | Verify DataNode and NodeManager ports are listening |
| 26 | `hdfs dfsadmin -getDatanodeInfo node04:9866` | Get detailed info for this DataNode |
| 27 | `yarn node -status node04:8042` | Check this node's status in YARN |
| 28 | `grep -i "heartbeat\|register" $HADOOP_HOME/logs/*-datanode-*.log \| tail -20` | Monitor DataNode heartbeat/registration events |
| 29 | `$HADOOP_HOME/bin/hdfs --daemon stop datanode` | Stop DataNode daemon (for maintenance) |
| 30 | `$HADOOP_HOME/bin/hdfs --daemon start datanode` | Restart DataNode daemon |
| 31 | `$HADOOP_HOME/bin/yarn --daemon stop nodemanager` | Stop NodeManager daemon |
| 32 | `$HADOOP_HOME/bin/yarn --daemon start nodemanager` | Restart NodeManager daemon |
| 33 | `vmstat 1 5` | Monitor system performance (5 samples) |
| 34 | `hdfs dfs -du -s -h /` | Summarize total HDFS disk usage |
| 35 | `history` | Show command history |

---

## node05 — Worker (DataNode · NodeManager)
> Services: **DataNode · NodeManager**

| # | Command | Purpose |
|---|---------|---------|
| 1 | `jps` | Check running JVM processes |
| 2 | `$HADOOP_HOME/bin/hdfs --daemon start datanode` | Start DataNode daemon |
| 3 | `$HADOOP_HOME/bin/yarn --daemon start nodemanager` | Start NodeManager daemon |
| 4 | `jps` | Verify DataNode and NodeManager are running |
| 5 | `hdfs dfs -ls /` | List root HDFS directory |
| 6 | `hdfs dfs -ls -R /user/` | Recursively list /user/ in HDFS |
| 7 | `df -h /hadoop/data/` | Check disk usage of Hadoop data directory |
| 8 | `df -h /` | Check disk usage of root filesystem |
| 9 | `tail -f $HADOOP_HOME/logs/*-datanode-*.log` | Stream DataNode logs live |
| 10 | `grep -i "ERROR\|FAILED\|lost" $HADOOP_HOME/logs/*-datanode-*.log \| tail -30` | Filter errors in DataNode log |
| 11 | `grep "disk\|volume" $HADOOP_HOME/logs/*-datanode-*.log \| tail -20` | Check for disk/volume issues in DataNode log |
| 12 | `grep -i "heartbeat\|register" $HADOOP_HOME/logs/*-datanode-*.log \| tail -20` | Monitor DataNode heartbeat/registration events |
| 13 | `tail -f $HADOOP_HOME/logs/*-nodemanager-*.log` | Stream NodeManager logs live |
| 14 | `grep -i "ERROR\|container\|launch" $HADOOP_HOME/logs/*-nodemanager-*.log \| tail -30` | Filter NodeManager container/launch errors |
| 15 | `clear` | Clear terminal |
| 16 | `yarn node -status node05:8042` | Check this node's status in YARN |
| 17 | `hdfs dfsadmin -getDatanodeInfo node05:9866` | Get detailed info for this DataNode |
| 18 | `du -sh /hadoop/data/*` | Summarize size of each data subdirectory |
| 19 | `iostat -xz 1 5` | Monitor disk I/O statistics (5 samples) |
| 20 | `free -h` | Check available memory |
| 21 | `top -bn1 \| head -20` | Snapshot of CPU/memory usage |
| 22 | `vmstat 1 5` | Monitor system performance (5 samples) |
| 23 | `netstat -tlnp \| grep -E "9864\|9866\|8042"` | Verify DataNode and NodeManager ports are listening |
| 24 | `$HADOOP_HOME/bin/hdfs --daemon stop datanode` | Stop DataNode daemon (for maintenance) |
| 25 | `$HADOOP_HOME/bin/hdfs --daemon start datanode` | Restart DataNode daemon |
| 26 | `$HADOOP_HOME/bin/yarn --daemon stop nodemanager` | Stop NodeManager daemon |
| 27 | `$HADOOP_HOME/bin/yarn --daemon start nodemanager` | Restart NodeManager daemon |
| 28 | `hdfs dfs -du -s -h /` | Summarize total HDFS disk usage |
| 29 | `grep -i "decommission\|replication" $HADOOP_HOME/logs/*-datanode-*.log \| tail -20` | Monitor decommission/replication events |
| 30 | `hdfs dfsadmin -report \| grep -A5 "node05"` | Show node05 section in HDFS admin report |
| 31 | `cat /proc/meminfo \| grep -E "MemTotal\|MemFree\|MemAvailable"` | Detailed memory stats |
| 32 | `lsblk -o NAME,SIZE,MOUNTPOINT` | List block devices and mount points |
| 33 | `hdfs dfs -count -q /user/` | Show quota usage for /user/ |
| 34 | `yarn logs -nodeId node05:8042` | Retrieve YARN logs for this node |
| 35 | `history` | Show command history |