#!/bin/bash

mkdir $OUTPUT_DIR
cd $OUTPUT_DIR

oc login --token=$OPENSHIFT_TOKEN --server=$OPENSHIFT_SERVER_URL

python openshift_metrics/openshift_prometheus_metrics.py --output-file output.log

/usr/bin/xdmod-shredder -f slurm -i output.log -r $XDMOD_RESOURCE
