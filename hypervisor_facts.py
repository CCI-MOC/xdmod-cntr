#!/usr/bin/python

import os
import json
import argparse
import logging
import datetime
import calendar
import requests
import glob
import openstack

def deep_compare(obj):
    if isinstance(obj, dict):
        return sorted((k, deep_compare(v)) for k, v in obj.items())
    if isinstance(obj, list):
        return sorted(deep_compare(x) for x in obj)
    else:
        return obj

def doParseArgs(config):
    """Parse args and return a config dict"""

    parser = argparse.ArgumentParser(description='Generate accounting records for OpenStack instances', epilog='-D and -A are mutually exclusive')
    parser.add_argument("-v", "--verbose", help="output debugging information", action="store_true")
    parser.add_argument("-C", "--config-file", help="Configuration file")
    parser.add_argument("-o", "--outdir", help="Output directory")

    args = parser.parse_args()


    config['loglevel']=logging.CRITICAL
    config['config_file'] = '/path/to/config.conf'

    if args.config_file:
        config['config_file'] = args.config_file

    config['outdir'] = '.'
    if args.outdir:
        config['outdir'] = args.outdir

    if args.verbose:
        config['loglevel']=logging.INFO

    return config

def doReadConfig(config):
    try:
        f = open(config['config_file'], 'r')
    except IOError:
        return
    else:
        newconfig = json.load(f)
        config.update(newconfig)

def getData(config):
 
    # TODO: add cloud parameter to config
    openstack_connection=openstack.connect(cloud='admin-kaizen')
    
    hvs=[]
    hv_status={}

    for nc in openstack_connection.compute.hypervisors(details=True):
        hv={}
        hv['id']=nc.id
        hv['hypervisor_hostname']=nc.name
        hv['vcpus']=nc.vcpus
        hv['memory_mb']=nc.memory_size
        hvs.append(hv)

    hv_status['hypervisors']=hvs
    ts = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    hv_status['ts']=ts
    return hv_status

def getLatestFacts(config):
    file_list = glob.glob(config['outdir'] + "//hypervisor_facts_*.json")

    if len(file_list) == 0:
        return {"hypervisors": []}

    newest = max(file_list, key=lambda d: datetime.datetime.strptime(d, "{}/hypervisor_facts_%Y-%m-%dT%H:%M:%S.json".format(config['outdir'])))

    f=open(newest, 'r')
    latest_facts=json.load(f)

    return latest_facts

def isNewData(config,data):
    latest_facts = getLatestFacts(config)
    if deep_compare(latest_facts['hypervisors']) == deep_compare(data['hypervisors']):
        logging.info("No new facts found")
        return False
    else:
        logging.info("New facts found")
        return True

def main ():

    config={}

    doParseArgs(config)
    doReadConfig(config)

    logging.basicConfig(
                format='%(asctime)s [%(levelname)s] %(message)s',
                datefmt='%Y-%m-%d %H:%M:%S',
                level=config['loglevel']
                )


    data = getData(config)

    if isNewData(config, data):
        nowtime = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S')
        json_out = "{}/hypervisor_facts_{}.json".format(config['outdir'], nowtime)
        with open(json_out, 'w') as outfile:
            json.dump(data, outfile, indent=2, sort_keys=True)

if __name__ == "__main__":
    main()
