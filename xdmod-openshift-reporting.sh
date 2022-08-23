#!/bin/bash

mkdir $OUTPUT_DIR
mkdir $OUTPUT_DIR/logs
cd $OUTPUT_DIR
export KUBECONFIG=.kubeconfig

echo "GENERATING OPENSHIFT LOG"
oc login --token=$OPENSHIFT_TOKEN --server=$OPENSHIFT_SERVER_URL
python3 /root/xdmod-openshift-scripts/openshift_metrics/openshift_prometheus_metrics.py

echo "SHREDDING DATA"
while
  SHREDDER_OUTPUT=`(/usr/bin/xdmod-shredder -f slurm -i *.log -r $XDMOD_RESOURCE) 2>&1`
  [[ "$SHREDDER_OUTPUT" == *"HY000"* ]]
do
  echo "Failed with"
  echo $SHREDDER_OUTPUT
  echo "Trying again in five seconds"
  sleep 5
done
echo $SHREDDER_OUTPUT

mv *.log $OUTPUT_DIR/logs/
echo "DONE"
