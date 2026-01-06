#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
  echo 'This script must be run as root' 1>&2
  exit 1
fi

NAME=JARfilenameByJps
NAMESPACE=JVM/$NAME

INSTANCE_ID=$(curl -s 169.254.169.254/latest/meta-data/instance-id)

PID=$(jps | grep "$NAME" | awk '{ print $1 }')
STS=$(jstat -gcutil "$PID" | tail -n 1)

S0=$(echo "$STS" | awk '{ print $1 }')
S1=$(echo "$STS" | awk '{ print $2 }')
E=$(echo "$STS" | awk '{ print $3 }')
O=$(echo "$STS" | awk '{ print $4 }')
M=$(echo "$STS" | awk '{ print $5 }')
CCS=$(echo "$STS" | awk '{ print $6 }')
YGC=$(echo "$STS" | awk '{ print $7 }')
YGCT=$(echo "$STS" | awk '{ print $8 }')
FGC=$(echo "$STS" | awk '{ print $9 }')
FGCT=$(echo "$STS" | awk '{ print $10 }')
GCT=$(echo "$STS" | awk '{ print $11 }')

aws cloudwatch put-metric-data \
--metric-name JVMSurvivor0Ratio \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value "$S0" \
--unit Percent

aws cloudwatch put-metric-data \
--metric-name JVMSurvivor1Ratio \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value "$S1" \
--unit Percent

aws cloudwatch put-metric-data \
--metric-name JVMEdenRatio \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value "$E" \
--unit Percent

aws cloudwatch put-metric-data \
--metric-name JVMOldRatio \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value "$O" \
--unit Percent

aws cloudwatch put-metric-data \
--metric-name JVMMetaRatio \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value "$M" \
--unit Percent

aws cloudwatch put-metric-data \
--metric-name JVMCompressedRatio \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value "$CCS" \
--unit Percent

aws cloudwatch put-metric-data \
--metric-name JVMYoungGCCount \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value "$YGC" \
--unit Count

aws cloudwatch put-metric-data \
--metric-name JVMYoungGCTime \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value "$YGCT" \
--unit Seconds

aws cloudwatch put-metric-data \
--metric-name JVMFullGCCount \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value "$FGC" \
--unit Count

aws cloudwatch put-metric-data \
--metric-name JVMFullGCTime \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value "$FGCT" \
--unit Seconds

aws cloudwatch put-metric-data \
--metric-name JVMTotalGCTime \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value "$GCT" \
--unit Seconds

PREV=/var/tmp/jvm.$PID

if [ -e "$PREV" ]; then
  PDAT=$(cat "$PREV")
else
  PDAT="$YGC $FGC"
fi

echo "$YGC" "$FGC" >"$PREV"
PYGC=$(echo "$PDAT" | awk '{ print $1 }')
PFGC=$(echo "$PDAT" | awk '{ print $2 }')

DYGC=$((YGC - PYGC))
DFGC=$((FGC - PFGC))

if [ $DYGC -le 0 ]; then
  DYGC=0
fi

if [ $DFGC -le 0 ]; then
  DFGC=0
fi

aws cloudwatch put-metric-data \
--metric-name JVMYoungGCCountDiff \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value $DYGC \
--unit Count

aws cloudwatch put-metric-data \
--metric-name JVMFullGCCountDiff \
--namespace "$NAMESPACE" \
--dimensions InstanceId="$INSTANCE_ID" \
--value $DFGC \
--unit Count
