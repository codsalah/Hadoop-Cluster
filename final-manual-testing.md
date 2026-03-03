## Hadoop HA Docker Cluster - Manual Test Run Log

- **Date**: $(date will be captured in commands section)
- **Host OS**: Linux (Ubuntu, kernel 6.17.0-14-generic)
- **Repository**: Hadoop-Cluster
- **Purpose**: End-to-end validation of Hadoop HDFS/YARN HA in Docker, including WordCount job and failover behavior, with explicit handling of startup races and Safemode.

---

### 1. Host Prerequisites Check

Commands and outputs will be recorded as executed below.

### 1. Host Prerequisites Check

#### Command
\$ docker --version
Docker version 29.2.1, build a5c7197

\$ docker compose version
Docker Compose version 2.37.1+ds1-0ubuntu2~24.04.1

\$ df -h .
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme1n1p2  915G  251G  618G  29% /

\$ systemctl is-active docker
active

### 2. Configuration File Validation

#### Command
\$ ls config/hadoop/
core-site.xml
hadoop-env.sh
hdfs-site.xml
mapred-site.xml
workers
yarn-site.xml

\$ ls config/zookeeper/
zoo.cfg

\$ xmllint --noout config/hadoop/core-site.xml && echo OK
OK

\$ xmllint --noout config/hdfs-site.xml && echo OK
OK

\$ xmllint --noout config/yarn-site.xml && echo OK
OK

\$ xmllint --noout config/mapred-site.xml && echo OK
OK

### 3. Launch Command

#### Command
\$ docker compose up -d

### 4. Container Status Verification

#### Command
\$ docker compose ps
NAME      IMAGE                   COMMAND                  SERVICE   CREATED              STATUS                      PORTS
node01    hadoop-cluster:latest   "/bin/sh -c 'service…"   node01    About a minute ago   Up 53 seconds (unhealthy)   0.0.0.0:2181->2181/tcp, [::]:2181->2181/tcp, 0.0.0.0:8081->8088/tcp, [::]:8081->8088/tcp, 0.0.0.0:8481->8480/tcp, [::]:8481->8480/tcp, 0.0.0.0:9871->9870/tcp, [::]:9871->9870/tcp
node02    hadoop-cluster:latest   "/bin/sh -c 'service…"   node02    14 minutes ago       Up 14 minutes               0.0.0.0:2182->2181/tcp, [::]:2182->2181/tcp, 0.0.0.0:8082->8088/tcp, [::]:8082->8088/tcp, 0.0.0.0:8482->8480/tcp, [::]:8482->8480/tcp, 0.0.0.0:9872->9870/tcp, [::]:9872->9870/tcp
node03    hadoop-cluster:latest   "/bin/sh -c 'service…"   node03    14 minutes ago       Up 14 minutes               0.0.0.0:2183->2181/tcp, [::]:2183->2181/tcp, 0.0.0.0:8083->8042/tcp, [::]:8083->8042/tcp, 0.0.0.0:8483->8480/tcp, [::]:8483->8480/tcp
node04    hadoop-cluster:latest   "/bin/sh -c 'service…"   node04    14 minutes ago       Up 14 minutes               0.0.0.0:8084->8042/tcp, [::]:8084->8042/tcp
node05    hadoop-cluster:latest   "/bin/sh -c 'service…"   node05    14 minutes ago       Up 14 minutes               0.0.0.0:8085->8042/tcp, [::]:8085->8042/tcp

### 5. ZooKeeper Service Startup Logs (node01)

#### Command
\$ docker exec node01 cat /opt/zookeeper/logs/zookeeper--server-node01.out
(log file not found or empty)

### 6. Verify ZooKeeper Quorum Status

#### Command
\$ docker exec node01 /opt/zookeeper/bin/zkServer.sh status
Client port found: 2181. Client address: localhost. Client SSL: false.
Error contacting service. It is probably not running.
(node01 zkServer.sh status failed)

\$ docker exec node02 /opt/zookeeper/bin/zkServer.sh status
Client port found: 2181. Client address: localhost. Client SSL: false.
Error contacting service. It is probably not running.
(node02 zkServer.sh status failed)

\$ docker exec node03 /opt/zookeeper/bin/zkServer.sh status
Client port found: 2181. Client address: localhost. Client SSL: false.
Error contacting service. It is probably not running.
(node03 zkServer.sh status failed)

### 7. Verify ZooKeeper Processes via jps

#### Command
\$ docker exec node01 jps | grep QuorumPeer || echo "(no QuorumPeer on node01)"
(no QuorumPeer on node01)

\$ docker exec node02 jps | grep QuorumPeer || echo "(no QuorumPeer on node02)"
(no QuorumPeer on node02)

\$ docker exec node03 jps | grep QuorumPeer || echo "(no QuorumPeer on node03)"
(no QuorumPeer on node03)

### 8. Start ZooKeeper on all three nodes (manual)

#### Command
\$ docker exec node01 /opt/zookeeper/bin/zkServer.sh start
Starting zookeeper ... STARTED

\$ docker exec node02 /opt/zookeeper/bin/zkServer.sh start
Starting zookeeper ... STARTED

\$ docker exec node03 /opt/zookeeper/bin/zkServer.sh start
Starting zookeeper ... STARTED

### 9. Re-verify ZooKeeper Quorum Status

#### Command
\$ docker exec node01 /opt/zookeeper/bin/zkServer.sh status
Client port found: 2181. Client address: localhost. Client SSL: false.
Error contacting service. It is probably not running.

\$ docker exec node02 /opt/zookeeper/bin/zkServer.sh status
Client port found: 2181. Client address: localhost. Client SSL: false.
Error contacting service. It is probably not running.

\$ docker exec node03 /opt/zookeeper/bin/zkServer.sh status
Client port found: 2181. Client address: localhost. Client SSL: false.
Error contacting service. It is probably not running.

### 10. jps on ZK nodes after start attempt

#### Command
\$ docker exec node01 jps
447 Jps

\$ docker exec node02 jps
190 Jps

\$ docker exec node03 jps
190 Jps

### 11. Inspect ZooKeeper logs directory on node01

#### Command
\$ docker exec node01 ls -R /opt/zookeeper/logs || echo "(logs dir missing)"
/opt/zookeeper/logs:
zookeeper--server-node01.out

### 12. Read ZooKeeper log on node01

#### Command
\$ docker exec node01 cat /opt/zookeeper/logs/zookeeper--server-node01.out | tail -50
03:59:14.066 [main] INFO org.apache.zookeeper.server.quorum.QuorumPeerConfig -- Reading configuration from: /opt/zookeeper/bin/../conf/zoo.cfg
03:59:14.080 [main] INFO org.apache.zookeeper.server.quorum.QuorumPeerConfig -- clientPortAddress is 0.0.0.0:2181
03:59:14.084 [main] INFO org.apache.zookeeper.server.quorum.QuorumPeerConfig -- secureClientPort is not set
03:59:14.084 [main] INFO org.apache.zookeeper.server.quorum.QuorumPeerConfig -- observerMasterPort is not set
03:59:14.084 [main] INFO org.apache.zookeeper.server.quorum.QuorumPeerConfig -- metricsProvider.className is org.apache.zookeeper.metrics.impl.DefaultMetricsProvider
03:59:14.104 [main] ERROR org.apache.zookeeper.server.quorum.QuorumPeerMain -- Invalid config, exiting abnormally
org.apache.zookeeper.server.quorum.QuorumPeerConfig$ConfigException: Error processing /opt/zookeeper/bin/../conf/zoo.cfg
	at org.apache.zookeeper.server.quorum.QuorumPeerConfig.parse(QuorumPeerConfig.java:198)
	at org.apache.zookeeper.server.quorum.QuorumPeerMain.initializeAndRun(QuorumPeerMain.java:125)
	at org.apache.zookeeper.server.quorum.QuorumPeerMain.main(QuorumPeerMain.java:91)
Caused by: java.lang.IllegalArgumentException: myid file is missing
	at org.apache.zookeeper.server.quorum.QuorumPeerConfig.checkValidity(QuorumPeerConfig.java:792)
	at org.apache.zookeeper.server.quorum.QuorumPeerConfig.setupQuorumPeerConfig(QuorumPeerConfig.java:663)
	at org.apache.zookeeper.server.quorum.QuorumPeerConfig.parseProperties(QuorumPeerConfig.java:487)
	at org.apache.zookeeper.server.quorum.QuorumPeerConfig.parse(QuorumPeerConfig.java:194)
	... 2 common frames omitted
Invalid config, exiting abnormally
03:59:14.111 [main] INFO org.apache.zookeeper.audit.ZKAuditProvider -- ZooKeeper audit is disabled.
03:59:14.115 [main] ERROR org.apache.zookeeper.util.ServiceUtils -- Exiting JVM with code 2

### 13. Create ZooKeeper myid files and restart ensemble

#### Command
\$ docker exec node01 sh -c "echo 1 > /var/zookeeper/myid && cat /var/zookeeper/myid"
1

\$ docker exec node02 sh -c "echo 2 > /var/zookeeper/myid && cat /var/zookeeper/myid"
2

\$ docker exec node03 sh -c "echo 3 > /var/zookeeper/myid && cat /var/zookeeper/myid"
3

\$ docker exec node01 /opt/zookeeper/bin/zkServer.sh start
Starting zookeeper ... STARTED

\$ docker exec node02 /opt/zookeeper/bin/zkServer.sh start
Starting zookeeper ... STARTED

\$ docker exec node03 /opt/zookeeper/bin/zkServer.sh start
Starting zookeeper ... STARTED

\$ docker exec node01 /opt/zookeeper/bin/zkServer.sh status
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: follower

\$ docker exec node02 /opt/zookeeper/bin/zkServer.sh status
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: leader

\$ docker exec node03 /opt/zookeeper/bin/zkServer.sh status
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: follower

### 14. JournalNode Startup (All Three Nodes)

#### Command
\$ docker exec node01 hdfs journalnode &
(started in background on node01)

\$ docker exec node02 hdfs journalnode &
(started in background on node02)

\$ docker exec node03 hdfs journalnode &
(started in background on node03)

\$ for n in node01 node02 node03; do echo -n "$n: "; docker exec $n jps | grep JournalNode; done
node01: 749 JournalNode
node02: 366 JournalNode
node03: 359 JournalNode

### 15. JournalNode HTTP Verification

#### Command
\$ curl -s -o /dev/null -w "%{http_code}" http://localhost:8481/
302

\$ curl -s -o /dev/null -w "%{http_code}" http://localhost:8482/
302

\$ curl -s -o /dev/null -w "%{http_code}" http://localhost:8483/
302

### 16. JournalNode Storage Directory

#### Command
\$ docker exec node01 ls /var/hadoop/journal/clusterA/
(clusterA dir missing)

\$ docker exec node01 ls /var/hadoop/journal/clusterA/current/
(current dir missing or empty)

### 17. ZooKeeper Failover Controller (ZKFC) Initialization

#### Command
\$ docker exec node01 hdfs zkfc -formatZK
2026-03-03 04:00:29,141 INFO  [main] tools.DFSZKFailoverController (StringUtils.java:startupShutdownMessage(809)) - STARTUP_MSG: 
/************************************************************
STARTUP_MSG: Starting DFSZKFailoverController
STARTUP_MSG:   host = node01/172.18.0.2
STARTUP_MSG:   args = [-formatZK]
STARTUP_MSG:   version = 3.4.2
STARTUP_MSG:   classpath = /opt/hadoop/etc/hadoop:/opt/hadoop/share/hadoop/common/lib/httpclient-4.5.13.jar:/opt/hadoop/share/hadoop/common/lib/netty-resolver-dns-classes-macos-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/avro-1.11.4.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-mqtt-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/commons-net-3.9.0.jar:/opt/hadoop/share/hadoop/common/lib/kerby-config-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-http2-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-resolver-dns-native-macos-4.1.118.Final-osx-aarch_64.jar:/opt/hadoop/share/hadoop/common/lib/curator-recipes-5.2.0.jar:/opt/hadoop/share/hadoop/common/lib/commons-codec-1.15.jar:/opt/hadoop/share/hadoop/common/lib/snappy-java-1.1.10.4.jar:/opt/hadoop/share/hadoop/common/lib/slf4j-api-1.7.36.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-udt-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-handler-ssl-ocsp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-stomp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/hadoop-shaded-protobuf_3_25-1.4.0.jar:/opt/hadoop/share/hadoop/common/lib/j2objc-annotations-1.1.jar:/opt/hadoop/share/hadoop/common/lib/jsr311-api-1.1.1.jar:/opt/hadoop/share/hadoop/common/lib/jetty-xml-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/failureaccess-1.0.jar:/opt/hadoop/share/hadoop/common/lib/metrics-core-3.2.4.jar:/opt/hadoop/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar:/opt/hadoop/share/hadoop/common/lib/jackson-annotations-2.12.7.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-kqueue-4.1.118.Final-osx-x86_64.jar:/opt/hadoop/share/hadoop/common/lib/netty-resolver-dns-native-macos-4.1.118.Final-osx-x86_64.jar:/opt/hadoop/share/hadoop/common/lib/guava-27.0-jre.jar:/opt/hadoop/share/hadoop/common/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop/share/hadoop/common/lib/jsp-api-2.1.jar:/opt/hadoop/share/hadoop/common/lib/gson-2.9.0.jar:/opt/hadoop/share/hadoop/common/lib/commons-cli-1.9.0.jar:/opt/hadoop/share/hadoop/common/lib/jersey-json-1.22.0.jar:/opt/hadoop/share/hadoop/common/lib/jul-to-slf4j-1.7.36.jar:/opt/hadoop/share/hadoop/common/lib/commons-io-2.16.1.jar:/opt/hadoop/share/hadoop/common/lib/jetty-util-ajax-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/jaxb-api-2.2.11.jar:/opt/hadoop/share/hadoop/common/lib/netty-common-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/jsch-0.1.55.jar:/opt/hadoop/share/hadoop/common/lib/nimbus-jose-jwt-9.37.2.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-sctp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-socks-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/commons-logging-1.3.0.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-epoll-4.1.118.Final-linux-aarch_64.jar:/opt/hadoop/share/hadoop/common/lib/netty-resolver-dns-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/woodstox-core-5.4.0.jar:/opt/hadoop/share/hadoop/common/lib/jersey-server-1.19.4.jar:/opt/hadoop/share/hadoop/common/lib/netty-resolver-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/commons-text-1.10.0.jar:/opt/hadoop/share/hadoop/common/lib/jackson-core-2.12.7.jar:/opt/hadoop/share/hadoop/common/lib/commons-configuration2-2.10.1.jar:/opt/hadoop/share/hadoop/common/lib/bcprov-jdk18on-1.78.1.jar:/opt/hadoop/share/hadoop/common/lib/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar:/opt/hadoop/share/hadoop/common/lib/zookeeper-jute-3.8.4.jar:/opt/hadoop/share/hadoop/common/lib/checker-qual-2.5.2.jar:/opt/hadoop/share/hadoop/common/lib/jackson-databind-2.12.7.1.jar:/opt/hadoop/share/hadoop/common/lib/jetty-util-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-epoll-4.1.118.Final-linux-riscv64.jar:/opt/hadoop/share/hadoop/common/lib/kerb-crypto-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/jetty-security-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/jersey-core-1.19.4.jar:/opt/hadoop/share/hadoop/common/lib/kerby-util-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/hadoop-auth-3.4.2.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-classes-kqueue-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-http-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/jetty-server-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/netty-all-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/curator-client-5.2.0.jar:/opt/hadoop/share/hadoop/common/lib/commons-math3-3.6.1.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-redis-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-kqueue-4.1.118.Final-osx-aarch_64.jar:/opt/hadoop/share/hadoop/common/lib/netty-handler-proxy-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/commons-compress-1.26.1.jar:/opt/hadoop/share/hadoop/common/lib/jettison-1.5.4.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-classes-epoll-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/animal-sniffer-annotations-1.17.jar:/opt/hadoop/share/hadoop/common/lib/audience-annotations-0.12.0.jar:/opt/hadoop/share/hadoop/common/lib/kerby-pkix-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/jersey-servlet-1.19.4.jar:/opt/hadoop/share/hadoop/common/lib/kerb-core-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/jetty-servlet-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/netty-handler-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-epoll-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-smtp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/stax2-api-4.2.1.jar:/opt/hadoop/share/hadoop/common/lib/netty-buffer-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/commons-collections4-4.4.jar:/opt/hadoop/share/hadoop/common/lib/commons-lang3-3.17.0.jar:/opt/hadoop/share/hadoop/common/lib/re2j-1.1.jar:/opt/hadoop/share/hadoop/common/lib/jsr305-3.0.2.jar:/opt/hadoop/share/hadoop/common/lib/reload4j-1.2.22.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/jcip-annotations-1.0-1.jar:/opt/hadoop/share/hadoop/common/lib/jakarta.activation-api-1.2.1.jar:/opt/hadoop/share/hadoop/common/lib/kerby-asn1-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-memcache-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-dns-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/zookeeper-3.8.4.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-haproxy-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/kerb-util-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/jetty-http-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/commons-daemon-1.0.13.jar:/opt/hadoop/share/hadoop/common/lib/hadoop-shaded-guava-1.4.0.jar:/opt/hadoop/share/hadoop/common/lib/httpcore-4.4.13.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-epoll-4.1.118.Final-linux-x86_64.jar:/opt/hadoop/share/hadoop/common/lib/jetty-webapp-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-xml-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-rxtx-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-unix-common-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/jetty-io-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/hadoop-annotations-3.4.2.jar:/opt/hadoop/share/hadoop/common/lib/javax.servlet-api-3.1.0.jar:/opt/hadoop/share/hadoop/common/lib/curator-framework-5.2.0.jar:/opt/hadoop/share/hadoop/common/lib/dnsjava-3.6.1.jar:/opt/hadoop/share/hadoop/common/hadoop-nfs-3.4.2.jar:/opt/hadoop/share/hadoop/common/hadoop-common-3.4.2.jar:/opt/hadoop/share/hadoop/common/hadoop-kms-3.4.2.jar:/opt/hadoop/share/hadoop/common/hadoop-registry-3.4.2.jar:/opt/hadoop/share/hadoop/common/hadoop-common-3.4.2-tests.jar:/opt/hadoop/share/hadoop/hdfs:/opt/hadoop/share/hadoop/hdfs/lib/httpclient-4.5.13.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-resolver-dns-classes-macos-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/avro-1.11.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-mqtt-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-net-3.9.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerby-config-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-http2-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-resolver-dns-native-macos-4.1.118.Final-osx-aarch_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/curator-recipes-5.2.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-codec-1.15.jar:/opt/hadoop/share/hadoop/hdfs/lib/snappy-java-1.1.10.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-udt-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-handler-ssl-ocsp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-stomp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/hadoop-shaded-protobuf_3_25-1.4.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/j2objc-annotations-1.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jsr311-api-1.1.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-xml-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/failureaccess-1.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/metrics-core-3.2.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/jackson-annotations-2.12.7.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-kqueue-4.1.118.Final-osx-x86_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-resolver-dns-native-macos-4.1.118.Final-osx-x86_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/guava-27.0-jre.jar:/opt/hadoop/share/hadoop/hdfs/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop/share/hadoop/hdfs/lib/gson-2.9.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-cli-1.9.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/jersey-json-1.22.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-io-2.16.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-util-ajax-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/jaxb-api-2.2.11.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-common-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/jsch-0.1.55.jar:/opt/hadoop/share/hadoop/hdfs/lib/nimbus-jose-jwt-9.37.2.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-sctp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-socks-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-logging-1.3.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-epoll-4.1.118.Final-linux-aarch_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-resolver-dns-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/woodstox-core-5.4.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/leveldbjni-all-1.8.jar:/opt/hadoop/share/hadoop/hdfs/lib/jersey-server-1.19.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-resolver-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-text-1.10.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/jackson-core-2.12.7.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-configuration2-2.10.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar:/opt/hadoop/share/hadoop/hdfs/lib/zookeeper-jute-3.8.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/checker-qual-2.5.2.jar:/opt/hadoop/share/hadoop/hdfs/lib/jackson-databind-2.12.7.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-util-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-epoll-4.1.118.Final-linux-riscv64.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerb-crypto-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/json-simple-1.1.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-security-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/jersey-core-1.19.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerby-util-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/hadoop-auth-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-classes-kqueue-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-http-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-server-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-all-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/curator-client-5.2.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-math3-3.6.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-redis-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-kqueue-4.1.118.Final-osx-aarch_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-handler-proxy-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-compress-1.26.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jettison-1.5.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-classes-epoll-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/animal-sniffer-annotations-1.17.jar:/opt/hadoop/share/hadoop/hdfs/lib/audience-annotations-0.12.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerby-pkix-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/jersey-servlet-1.19.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerb-core-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-servlet-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-handler-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-epoll-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-smtp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/stax2-api-4.2.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-buffer-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-collections4-4.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-lang3-3.17.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/re2j-1.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jsr305-3.0.2.jar:/opt/hadoop/share/hadoop/hdfs/lib/reload4j-1.2.22.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/jcip-annotations-1.0-1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jakarta.activation-api-1.2.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerby-asn1-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-memcache-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-dns-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/zookeeper-3.8.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-haproxy-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerb-util-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-http-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-daemon-1.0.13.jar:/opt/hadoop/share/hadoop/hdfs/lib/hadoop-shaded-guava-1.4.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/httpcore-4.4.13.jar:/opt/hadoop/share/hadoop/hdfs/lib/HikariCP-4.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-epoll-4.1.118.Final-linux-x86_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-webapp-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-xml-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-rxtx-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-unix-common-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-io-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/hadoop-annotations-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/lib/javax.servlet-api-3.1.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/curator-framework-5.2.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/dnsjava-3.6.1.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-3.4.2-tests.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-native-client-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-nfs-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-client-3.4.2-tests.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-httpfs-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-client-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-rbf-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-rbf-3.4.2-tests.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-native-client-3.4.2-tests.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-plugins-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-common-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-shuffle-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-uploader-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-nativetask-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-core-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.2-tests.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-app-3.4.2.jar:/opt/hadoop/share/hadoop/yarn:/opt/hadoop/share/hadoop/yarn/lib/jackson-jaxrs-base-2.12.7.jar:/opt/hadoop/share/hadoop/yarn/lib/stax-ex-1.8.jar:/opt/hadoop/share/hadoop/yarn/lib/javax.inject-1.jar:/opt/hadoop/share/hadoop/yarn/lib/websocket-client-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/javax-websocket-client-impl-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/jna-5.2.0.jar:/opt/hadoop/share/hadoop/yarn/lib/asm-commons-9.7.1.jar:/opt/hadoop/share/hadoop/yarn/lib/javax-websocket-server-impl-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/websocket-server-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/bcutil-jdk18on-1.78.1.jar:/opt/hadoop/share/hadoop/yarn/lib/commons-lang-2.6.jar:/opt/hadoop/share/hadoop/yarn/lib/javax.websocket-client-api-1.0.jar:/opt/hadoop/share/hadoop/yarn/lib/mssql-jdbc-6.2.1.jre7.jar:/opt/hadoop/share/hadoop/yarn/lib/javax.activation-api-1.2.0.jar:/opt/hadoop/share/hadoop/yarn/lib/asm-tree-9.7.1.jar:/opt/hadoop/share/hadoop/yarn/lib/txw2-2.3.1.jar:/opt/hadoop/share/hadoop/yarn/lib/codemodel-2.6.jar:/opt/hadoop/share/hadoop/yarn/lib/guice-servlet-4.2.3.jar:/opt/hadoop/share/hadoop/yarn/lib/jetty-plus-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/websocket-common-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/jakarta.xml.bind-api-2.3.2.jar:/opt/hadoop/share/hadoop/yarn/lib/jackson-module-jaxb-annotations-2.12.7.jar:/opt/hadoop/share/hadoop/yarn/lib/aopalliance-1.0.jar:/opt/hadoop/share/hadoop/yarn/lib/snakeyaml-2.0.jar:/opt/hadoop/share/hadoop/yarn/lib/jersey-guice-1.19.4.jar:/opt/hadoop/share/hadoop/yarn/lib/jaxb-runtime-2.3.1.jar:/opt/hadoop/share/hadoop/yarn/lib/jetty-annotations-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/istack-commons-runtime-3.0.7.jar:/opt/hadoop/share/hadoop/yarn/lib/jetty-client-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/swagger-annotations-1.5.4.jar:/opt/hadoop/share/hadoop/yarn/lib/jetty-jndi-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/cache-api-1.1.1.jar:/opt/hadoop/share/hadoop/yarn/lib/ehcache-3.8.2.jar:/opt/hadoop/share/hadoop/yarn/lib/guice-4.2.3.jar:/opt/hadoop/share/hadoop/yarn/lib/websocket-servlet-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/jackson-jaxrs-json-provider-2.12.7.jar:/opt/hadoop/share/hadoop/yarn/lib/bcpkix-jdk18on-1.78.1.jar:/opt/hadoop/share/hadoop/yarn/lib/javax.websocket-api-1.0.jar:/opt/hadoop/share/hadoop/yarn/lib/jline-3.9.0.jar:/opt/hadoop/share/hadoop/yarn/lib/jersey-client-1.19.4.jar:/opt/hadoop/share/hadoop/yarn/lib/objenesis-2.6.jar:/opt/hadoop/share/hadoop/yarn/lib/jsonschema2pojo-core-1.0.2.jar:/opt/hadoop/share/hadoop/yarn/lib/FastInfoset-1.2.15.jar:/opt/hadoop/share/hadoop/yarn/lib/websocket-api-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/fst-2.50.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-globalpolicygenerator-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-applications-distributedshell-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-timeline-pluginstorage-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-applicationhistoryservice-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-services-core-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-sharedcachemanager-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-applications-mawo-core-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-services-api-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-resourcemanager-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-applications-unmanaged-am-launcher-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-registry-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-web-proxy-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-client-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-api-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-common-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-nodemanager-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-tests-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-common-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-router-3.4.2.jar
STARTUP_MSG:   build = https://github.com/apache/hadoop.git -r 84e8b89ee2ebe6923691205b9e171badde7a495c; compiled by 'ahmarsu' on 2025-08-20T10:30Z
STARTUP_MSG:   java = 11.0.30
************************************************************/
2026-03-03 04:00:29,188 INFO  [main] tools.DFSZKFailoverController (SignalLogger.java:register(91)) - registered UNIX signal handlers for [TERM, HUP, INT]
2026-03-03 04:00:30,118 INFO  [main] tools.DFSZKFailoverController (DFSZKFailoverController.java:<init>(177)) - Failover controller configured for NameNode NameNode at node01/172.18.0.2:8020
2026-03-03 04:00:30,608 INFO  [main] common.X509Util (X509Util.java:<clinit>(78)) - Setting -D jdk.tls.rejectClientInitiatedRenegotiation=true to disable client-initiated TLS renegotiation
2026-03-03 04:00:30,624 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:zookeeper.version=3.8.4-9316c2a7a97e1666d8f4593f34dd6fc36ecc436c, built on 2024-02-12 22:16 UTC
2026-03-03 04:00:30,624 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:host.name=node01
2026-03-03 04:00:30,625 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:java.version=11.0.30
2026-03-03 04:00:30,625 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:java.vendor=Ubuntu
2026-03-03 04:00:30,625 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:java.home=/usr/lib/jvm/java-11-openjdk-amd64
2026-03-03 04:00:30,625 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:java.class.path=/opt/hadoop/etc/hadoop:/opt/hadoop/share/hadoop/common/lib/httpclient-4.5.13.jar:/opt/hadoop/share/hadoop/common/lib/netty-resolver-dns-classes-macos-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/avro-1.11.4.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-mqtt-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/commons-net-3.9.0.jar:/opt/hadoop/share/hadoop/common/lib/kerby-config-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-http2-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-resolver-dns-native-macos-4.1.118.Final-osx-aarch_64.jar:/opt/hadoop/share/hadoop/common/lib/curator-recipes-5.2.0.jar:/opt/hadoop/share/hadoop/common/lib/commons-codec-1.15.jar:/opt/hadoop/share/hadoop/common/lib/snappy-java-1.1.10.4.jar:/opt/hadoop/share/hadoop/common/lib/slf4j-api-1.7.36.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-udt-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-handler-ssl-ocsp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-stomp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/hadoop-shaded-protobuf_3_25-1.4.0.jar:/opt/hadoop/share/hadoop/common/lib/j2objc-annotations-1.1.jar:/opt/hadoop/share/hadoop/common/lib/jsr311-api-1.1.1.jar:/opt/hadoop/share/hadoop/common/lib/jetty-xml-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/failureaccess-1.0.jar:/opt/hadoop/share/hadoop/common/lib/metrics-core-3.2.4.jar:/opt/hadoop/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar:/opt/hadoop/share/hadoop/common/lib/jackson-annotations-2.12.7.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-kqueue-4.1.118.Final-osx-x86_64.jar:/opt/hadoop/share/hadoop/common/lib/netty-resolver-dns-native-macos-4.1.118.Final-osx-x86_64.jar:/opt/hadoop/share/hadoop/common/lib/guava-27.0-jre.jar:/opt/hadoop/share/hadoop/common/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop/share/hadoop/common/lib/jsp-api-2.1.jar:/opt/hadoop/share/hadoop/common/lib/gson-2.9.0.jar:/opt/hadoop/share/hadoop/common/lib/commons-cli-1.9.0.jar:/opt/hadoop/share/hadoop/common/lib/jersey-json-1.22.0.jar:/opt/hadoop/share/hadoop/common/lib/jul-to-slf4j-1.7.36.jar:/opt/hadoop/share/hadoop/common/lib/commons-io-2.16.1.jar:/opt/hadoop/share/hadoop/common/lib/jetty-util-ajax-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/jaxb-api-2.2.11.jar:/opt/hadoop/share/hadoop/common/lib/netty-common-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/jsch-0.1.55.jar:/opt/hadoop/share/hadoop/common/lib/nimbus-jose-jwt-9.37.2.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-sctp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-socks-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/commons-logging-1.3.0.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-epoll-4.1.118.Final-linux-aarch_64.jar:/opt/hadoop/share/hadoop/common/lib/netty-resolver-dns-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/woodstox-core-5.4.0.jar:/opt/hadoop/share/hadoop/common/lib/jersey-server-1.19.4.jar:/opt/hadoop/share/hadoop/common/lib/netty-resolver-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/commons-text-1.10.0.jar:/opt/hadoop/share/hadoop/common/lib/jackson-core-2.12.7.jar:/opt/hadoop/share/hadoop/common/lib/commons-configuration2-2.10.1.jar:/opt/hadoop/share/hadoop/common/lib/bcprov-jdk18on-1.78.1.jar:/opt/hadoop/share/hadoop/common/lib/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar:/opt/hadoop/share/hadoop/common/lib/zookeeper-jute-3.8.4.jar:/opt/hadoop/share/hadoop/common/lib/checker-qual-2.5.2.jar:/opt/hadoop/share/hadoop/common/lib/jackson-databind-2.12.7.1.jar:/opt/hadoop/share/hadoop/common/lib/jetty-util-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-epoll-4.1.118.Final-linux-riscv64.jar:/opt/hadoop/share/hadoop/common/lib/kerb-crypto-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/jetty-security-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/jersey-core-1.19.4.jar:/opt/hadoop/share/hadoop/common/lib/kerby-util-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/hadoop-auth-3.4.2.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-classes-kqueue-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-http-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/jetty-server-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/netty-all-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/curator-client-5.2.0.jar:/opt/hadoop/share/hadoop/common/lib/commons-math3-3.6.1.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-redis-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-kqueue-4.1.118.Final-osx-aarch_64.jar:/opt/hadoop/share/hadoop/common/lib/netty-handler-proxy-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/commons-compress-1.26.1.jar:/opt/hadoop/share/hadoop/common/lib/jettison-1.5.4.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-classes-epoll-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/animal-sniffer-annotations-1.17.jar:/opt/hadoop/share/hadoop/common/lib/audience-annotations-0.12.0.jar:/opt/hadoop/share/hadoop/common/lib/kerby-pkix-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/jersey-servlet-1.19.4.jar:/opt/hadoop/share/hadoop/common/lib/kerb-core-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/jetty-servlet-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/netty-handler-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-epoll-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-smtp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/stax2-api-4.2.1.jar:/opt/hadoop/share/hadoop/common/lib/netty-buffer-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/commons-collections4-4.4.jar:/opt/hadoop/share/hadoop/common/lib/commons-lang3-3.17.0.jar:/opt/hadoop/share/hadoop/common/lib/re2j-1.1.jar:/opt/hadoop/share/hadoop/common/lib/jsr305-3.0.2.jar:/opt/hadoop/share/hadoop/common/lib/reload4j-1.2.22.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/jcip-annotations-1.0-1.jar:/opt/hadoop/share/hadoop/common/lib/jakarta.activation-api-1.2.1.jar:/opt/hadoop/share/hadoop/common/lib/kerby-asn1-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-memcache-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-dns-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/zookeeper-3.8.4.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-haproxy-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/kerb-util-2.0.3.jar:/opt/hadoop/share/hadoop/common/lib/jetty-http-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/commons-daemon-1.0.13.jar:/opt/hadoop/share/hadoop/common/lib/hadoop-shaded-guava-1.4.0.jar:/opt/hadoop/share/hadoop/common/lib/httpcore-4.4.13.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-epoll-4.1.118.Final-linux-x86_64.jar:/opt/hadoop/share/hadoop/common/lib/jetty-webapp-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/netty-codec-xml-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-rxtx-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/netty-transport-native-unix-common-4.1.118.Final.jar:/opt/hadoop/share/hadoop/common/lib/jetty-io-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/common/lib/hadoop-annotations-3.4.2.jar:/opt/hadoop/share/hadoop/common/lib/javax.servlet-api-3.1.0.jar:/opt/hadoop/share/hadoop/common/lib/curator-framework-5.2.0.jar:/opt/hadoop/share/hadoop/common/lib/dnsjava-3.6.1.jar:/opt/hadoop/share/hadoop/common/hadoop-nfs-3.4.2.jar:/opt/hadoop/share/hadoop/common/hadoop-common-3.4.2.jar:/opt/hadoop/share/hadoop/common/hadoop-kms-3.4.2.jar:/opt/hadoop/share/hadoop/common/hadoop-registry-3.4.2.jar:/opt/hadoop/share/hadoop/common/hadoop-common-3.4.2-tests.jar:/opt/hadoop/share/hadoop/hdfs:/opt/hadoop/share/hadoop/hdfs/lib/httpclient-4.5.13.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-resolver-dns-classes-macos-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/avro-1.11.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-mqtt-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-net-3.9.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerby-config-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-http2-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-resolver-dns-native-macos-4.1.118.Final-osx-aarch_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/curator-recipes-5.2.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-codec-1.15.jar:/opt/hadoop/share/hadoop/hdfs/lib/snappy-java-1.1.10.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-udt-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-handler-ssl-ocsp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-stomp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/hadoop-shaded-protobuf_3_25-1.4.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/j2objc-annotations-1.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jsr311-api-1.1.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-xml-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/failureaccess-1.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/metrics-core-3.2.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/jackson-annotations-2.12.7.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-kqueue-4.1.118.Final-osx-x86_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-resolver-dns-native-macos-4.1.118.Final-osx-x86_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/guava-27.0-jre.jar:/opt/hadoop/share/hadoop/hdfs/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop/share/hadoop/hdfs/lib/gson-2.9.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-cli-1.9.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/jersey-json-1.22.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-io-2.16.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-util-ajax-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/jaxb-api-2.2.11.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-common-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/jsch-0.1.55.jar:/opt/hadoop/share/hadoop/hdfs/lib/nimbus-jose-jwt-9.37.2.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-sctp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-socks-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-logging-1.3.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-epoll-4.1.118.Final-linux-aarch_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-resolver-dns-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/woodstox-core-5.4.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/leveldbjni-all-1.8.jar:/opt/hadoop/share/hadoop/hdfs/lib/jersey-server-1.19.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-resolver-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-text-1.10.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/jackson-core-2.12.7.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-configuration2-2.10.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar:/opt/hadoop/share/hadoop/hdfs/lib/zookeeper-jute-3.8.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/checker-qual-2.5.2.jar:/opt/hadoop/share/hadoop/hdfs/lib/jackson-databind-2.12.7.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-util-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-epoll-4.1.118.Final-linux-riscv64.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerb-crypto-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/json-simple-1.1.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-security-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/jersey-core-1.19.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerby-util-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/hadoop-auth-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-classes-kqueue-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-http-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-server-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-all-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/curator-client-5.2.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-math3-3.6.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-redis-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-kqueue-4.1.118.Final-osx-aarch_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-handler-proxy-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-compress-1.26.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jettison-1.5.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-classes-epoll-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/animal-sniffer-annotations-1.17.jar:/opt/hadoop/share/hadoop/hdfs/lib/audience-annotations-0.12.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerby-pkix-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/jersey-servlet-1.19.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerb-core-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-servlet-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-handler-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-epoll-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-smtp-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/stax2-api-4.2.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-buffer-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-collections4-4.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-lang3-3.17.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/re2j-1.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jsr305-3.0.2.jar:/opt/hadoop/share/hadoop/hdfs/lib/reload4j-1.2.22.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/jcip-annotations-1.0-1.jar:/opt/hadoop/share/hadoop/hdfs/lib/jakarta.activation-api-1.2.1.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerby-asn1-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-memcache-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-dns-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/zookeeper-3.8.4.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-haproxy-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/kerb-util-2.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-http-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/commons-daemon-1.0.13.jar:/opt/hadoop/share/hadoop/hdfs/lib/hadoop-shaded-guava-1.4.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/httpcore-4.4.13.jar:/opt/hadoop/share/hadoop/hdfs/lib/HikariCP-4.0.3.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-epoll-4.1.118.Final-linux-x86_64.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-webapp-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-codec-xml-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-rxtx-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/netty-transport-native-unix-common-4.1.118.Final.jar:/opt/hadoop/share/hadoop/hdfs/lib/jetty-io-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/hdfs/lib/hadoop-annotations-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/lib/javax.servlet-api-3.1.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/curator-framework-5.2.0.jar:/opt/hadoop/share/hadoop/hdfs/lib/dnsjava-3.6.1.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-3.4.2-tests.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-native-client-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-nfs-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-client-3.4.2-tests.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-httpfs-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-client-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-rbf-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-rbf-3.4.2-tests.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-3.4.2.jar:/opt/hadoop/share/hadoop/hdfs/hadoop-hdfs-native-client-3.4.2-tests.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-plugins-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-common-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-shuffle-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-uploader-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-nativetask-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-core-3.4.2.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.2-tests.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-app-3.4.2.jar:/opt/hadoop/share/hadoop/yarn:/opt/hadoop/share/hadoop/yarn/lib/jackson-jaxrs-base-2.12.7.jar:/opt/hadoop/share/hadoop/yarn/lib/stax-ex-1.8.jar:/opt/hadoop/share/hadoop/yarn/lib/javax.inject-1.jar:/opt/hadoop/share/hadoop/yarn/lib/websocket-client-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/javax-websocket-client-impl-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/jna-5.2.0.jar:/opt/hadoop/share/hadoop/yarn/lib/asm-commons-9.7.1.jar:/opt/hadoop/share/hadoop/yarn/lib/javax-websocket-server-impl-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/websocket-server-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/bcutil-jdk18on-1.78.1.jar:/opt/hadoop/share/hadoop/yarn/lib/commons-lang-2.6.jar:/opt/hadoop/share/hadoop/yarn/lib/javax.websocket-client-api-1.0.jar:/opt/hadoop/share/hadoop/yarn/lib/mssql-jdbc-6.2.1.jre7.jar:/opt/hadoop/share/hadoop/yarn/lib/javax.activation-api-1.2.0.jar:/opt/hadoop/share/hadoop/yarn/lib/asm-tree-9.7.1.jar:/opt/hadoop/share/hadoop/yarn/lib/txw2-2.3.1.jar:/opt/hadoop/share/hadoop/yarn/lib/codemodel-2.6.jar:/opt/hadoop/share/hadoop/yarn/lib/guice-servlet-4.2.3.jar:/opt/hadoop/share/hadoop/yarn/lib/jetty-plus-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/websocket-common-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/jakarta.xml.bind-api-2.3.2.jar:/opt/hadoop/share/hadoop/yarn/lib/jackson-module-jaxb-annotations-2.12.7.jar:/opt/hadoop/share/hadoop/yarn/lib/aopalliance-1.0.jar:/opt/hadoop/share/hadoop/yarn/lib/snakeyaml-2.0.jar:/opt/hadoop/share/hadoop/yarn/lib/jersey-guice-1.19.4.jar:/opt/hadoop/share/hadoop/yarn/lib/jaxb-runtime-2.3.1.jar:/opt/hadoop/share/hadoop/yarn/lib/jetty-annotations-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/istack-commons-runtime-3.0.7.jar:/opt/hadoop/share/hadoop/yarn/lib/jetty-client-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/swagger-annotations-1.5.4.jar:/opt/hadoop/share/hadoop/yarn/lib/jetty-jndi-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/cache-api-1.1.1.jar:/opt/hadoop/share/hadoop/yarn/lib/ehcache-3.8.2.jar:/opt/hadoop/share/hadoop/yarn/lib/guice-4.2.3.jar:/opt/hadoop/share/hadoop/yarn/lib/websocket-servlet-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/jackson-jaxrs-json-provider-2.12.7.jar:/opt/hadoop/share/hadoop/yarn/lib/bcpkix-jdk18on-1.78.1.jar:/opt/hadoop/share/hadoop/yarn/lib/javax.websocket-api-1.0.jar:/opt/hadoop/share/hadoop/yarn/lib/jline-3.9.0.jar:/opt/hadoop/share/hadoop/yarn/lib/jersey-client-1.19.4.jar:/opt/hadoop/share/hadoop/yarn/lib/objenesis-2.6.jar:/opt/hadoop/share/hadoop/yarn/lib/jsonschema2pojo-core-1.0.2.jar:/opt/hadoop/share/hadoop/yarn/lib/FastInfoset-1.2.15.jar:/opt/hadoop/share/hadoop/yarn/lib/websocket-api-9.4.57.v20241219.jar:/opt/hadoop/share/hadoop/yarn/lib/fst-2.50.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-globalpolicygenerator-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-applications-distributedshell-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-timeline-pluginstorage-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-applicationhistoryservice-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-services-core-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-sharedcachemanager-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-applications-mawo-core-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-services-api-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-resourcemanager-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-applications-unmanaged-am-launcher-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-registry-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-web-proxy-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-client-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-api-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-common-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-nodemanager-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-tests-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-common-3.4.2.jar:/opt/hadoop/share/hadoop/yarn/hadoop-yarn-server-router-3.4.2.jar
2026-03-03 04:00:30,626 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:java.library.path=/opt/hadoop/lib/native
2026-03-03 04:00:30,626 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:java.io.tmpdir=/tmp
2026-03-03 04:00:30,627 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:java.compiler=<NA>
2026-03-03 04:00:30,627 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:os.name=Linux
2026-03-03 04:00:30,627 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:os.arch=amd64
2026-03-03 04:00:30,627 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:os.version=6.17.0-14-generic
2026-03-03 04:00:30,628 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:user.name=root
2026-03-03 04:00:30,628 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:user.home=/root
2026-03-03 04:00:30,628 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:user.dir=/
2026-03-03 04:00:30,629 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:os.memory.free=225MB
2026-03-03 04:00:30,629 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:os.memory.max=3904MB
2026-03-03 04:00:30,629 INFO  [main] zookeeper.ZooKeeper (Environment.java:logEnv(98)) - Client environment:os.memory.total=246MB
2026-03-03 04:00:30,635 INFO  [main] zookeeper.ZooKeeper (ZooKeeper.java:<init>(637)) - Initiating client connection, connectString=node01:2181,node02:2181,node03:2181 sessionTimeout=10000 watcher=org.apache.hadoop.ha.ActiveStandbyElector$WatcherWithClientRef@42e25b0b
2026-03-03 04:00:30,645 INFO  [main] zookeeper.ClientCnxnSocket (ClientCnxnSocket.java:initProperties(239)) - jute.maxbuffer value is 1048575 Bytes
2026-03-03 04:00:30,669 INFO  [main] zookeeper.ClientCnxn (ClientCnxn.java:initRequestTimeout(1747)) - zookeeper.request.timeout value is 0. feature enabled=false
2026-03-03 04:00:30,697 INFO  [main-SendThread(node02:2181)] zookeeper.ClientCnxn (ClientCnxn.java:logStartConnect(1177)) - Opening socket connection to server node02/172.18.0.4:2181.
2026-03-03 04:00:30,698 INFO  [main-SendThread(node02:2181)] zookeeper.ClientCnxn (ClientCnxn.java:logStartConnect(1179)) - SASL config status: Will not attempt to authenticate using SASL (unknown error)
2026-03-03 04:00:30,717 INFO  [main-SendThread(node02:2181)] zookeeper.ClientCnxn (ClientCnxn.java:primeConnection(1013)) - Socket connection established, initiating session, client: /172.18.0.2:40722, server: node02/172.18.0.4:2181
2026-03-03 04:00:30,767 INFO  [main-SendThread(node02:2181)] zookeeper.ClientCnxn (ClientCnxn.java:onConnected(1453)) - Session establishment complete on server node02/172.18.0.4:2181, session id = 0x2000268112b0000, negotiated timeout = 10000
2026-03-03 04:00:30,778 INFO  [main-EventThread] ha.ActiveStandbyElector (ActiveStandbyElector.java:processWatchEvent(649)) - Session connected.
2026-03-03 04:00:30,859 INFO  [main] ha.ActiveStandbyElector (ActiveStandbyElector.java:ensureParentZNode(395)) - Successfully created /hadoop-ha/clusterA in ZK.
2026-03-03 04:00:30,981 INFO  [main] zookeeper.ZooKeeper (ZooKeeper.java:close(1232)) - Session: 0x2000268112b0000 closed
2026-03-03 04:00:30,982 WARN  [main-EventThread] ha.ActiveStandbyElector (ActiveStandbyElector.java:isStaleClient(1176)) - Ignoring stale result from old client with sessionId 0x2000268112b0000
2026-03-03 04:00:30,983 INFO  [main-EventThread] zookeeper.ClientCnxn (ClientCnxn.java:run(569)) - EventThread shut down for session: 0x2000268112b0000
2026-03-03 04:00:30,987 INFO  [shutdown-hook-0] tools.DFSZKFailoverController (StringUtils.java:run(822)) - SHUTDOWN_MSG: 
/************************************************************
SHUTDOWN_MSG: Shutting down DFSZKFailoverController at node01/172.18.0.2
************************************************************/
