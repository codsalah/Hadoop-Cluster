#!/bin/bash
# verify-cluster.sh — Cluster health verification
set -e

echo "============================================================"
echo "  HA Hadoop Cluster Verification"
echo "============================================================"

PASS=0
FAIL=0

# function to check if the cluster (HDFS, YARN, ZooKeeper) is healthy
check() {
    # desc: description of the check
    # expected: expected output
    # actual: actual output
    local desc="$1"
    local expected="$2"
    local actual="$3"
    if echo "$actual" | grep -qi "$expected"; then
        echo "  [OK] $desc"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] $desc (expected: $expected, got: $actual)"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "[ HDFS HA States ]"
NN1_STATE=$(hdfs haadmin -getServiceState nn1 2>/dev/null || echo "ERROR")
NN2_STATE=$(hdfs haadmin -getServiceState nn2 2>/dev/null || echo "ERROR")
echo "  nn1 (node01): $NN1_STATE"
echo "  nn2 (node02): $NN2_STATE"

if [[ ("$NN1_STATE" == "active" && "$NN2_STATE" == "standby") || ("$NN1_STATE" == "standby" && "$NN2_STATE" == "active") ]]; then
    echo "  [OK] HDFS HA pair is healthy"
    PASS=$((PASS + 1))
else
    echo "  [FAIL] HDFS HA pair is in invalid state"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "[ YARN HA States ]"
RM1_STATE=$(yarn rmadmin -getServiceState rm1 2>/dev/null || echo "ERROR")
RM2_STATE=$(yarn rmadmin -getServiceState rm2 2>/dev/null || echo "ERROR")
echo "  rm1 (node01): $RM1_STATE"
echo "  rm2 (node02): $RM2_STATE"

if [[ ("$RM1_STATE" == "active" && "$RM2_STATE" == "standby") || ("$RM1_STATE" == "standby" && "$RM2_STATE" == "active") ]]; then
    echo "  [OK] YARN HA pair is healthy"
    PASS=$((PASS + 1))
else
    echo "  [FAIL] YARN HA pair is in invalid state"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "[ HDFS DataNode Report ]"
DN_REPORT=$(hdfs dfsadmin -report 2>/dev/null || echo "")
DN_LIVE=$(echo "$DN_REPORT" | grep "Live datanodes" | awk '{print $3}' | tr -d '():')
if [ "$DN_LIVE" = "3" ]; then
    echo "  [OK] 3 Live DataNodes"
    PASS=$((PASS + 1))
else
    echo "  [FAIL] Expected 3 DataNodes, got: ${DN_LIVE:-0}"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "[ ZooKeeper ]"
# Fallback check for ZK
ZK_OK=false
if echo "ruok" | nc node01 2181 2>/dev/null | grep -q "imok"; then ZK_OK=true; fi
if ! $ZK_OK; then jps | grep -q QuorumPeerMain && ZK_OK=true; fi

if $ZK_OK; then
    echo "  [OK] ZooKeeper responding"
    PASS=$((PASS + 1))
else
    echo "  [FAIL] ZooKeeper not detected"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "[ JVM Processes on $(hostname) ]"
jps

echo ""
echo "============================================================"
echo "  Checks passed: $PASS"
echo "  Checks failed: $FAIL"
if [ "$FAIL" -eq 0 ]; then
    echo "  Summary: Cluster is healthy"
else
    echo "  Summary: Issues detected"
fi
echo "============================================================"

echo ""
echo "  Web UIs:"
echo "    HDFS NameNode (Active):  http://localhost:9871"
echo "    HDFS NameNode (Standby): http://localhost:9872"
echo "    YARN RM (Active):        http://localhost:8081"
echo "    YARN RM (Standby):       http://localhost:8082"
echo "============================================================"
