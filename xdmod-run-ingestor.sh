#!/usr/bin/sh

cp /mnt/xdmod_init/xdmod_init.json /etc/xdmod/xdmod_init.json
/usr/bin/xdmod-get-config-files 
/usr/bin/xdmod-ingestor
