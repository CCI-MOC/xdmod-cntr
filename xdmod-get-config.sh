#!/bin/bash

cp /mnt/xdmod_init/xdmod_init.json /etc/xdmod/xdmod_init.json
/usr/bin/xdmod-get-config-files
cp /etc/xdmod/clouds.yaml /etc/openstack/clouds.yaml 
