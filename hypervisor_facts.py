#!/usr/bin/python3
""" This just returns the hypervisor facts """

import json
import argparse
import logging
import datetime
import glob
import openstack


def deep_compare(obj):
    """compares each item in a object or a dictionary"""
    if isinstance(obj, dict):
        return sorted((k, deep_compare(v)) for k, v in obj.items())
    if isinstance(obj, list):
        return sorted(deep_compare(x) for x in obj)
    return obj


def do_parse_args(config):
    """Parse args and return a config dict"""
    parser = argparse.ArgumentParser(
        description="Generate accounting records for OpenStack instances",
        epilog="-D and -A are mutually exclusive",
    )
    parser.add_argument(
        "-v", "--verbose", help="output debugging information", action="store_true"
    )
    parser.add_argument("-C", "--config-file", help="Configuration file")
    parser.add_argument("-o", "--outdir", help="Output directory")
    parser.add_argument("--cloud", help="cloud name (in .config/openstack/cloud.json)")

    args = parser.parse_args()

    config["loglevel"] = logging.CRITICAL
    config["config_file"] = "/path/to/config.conf"

    if args.config_file:
        config["config_file"] = args.config_file

    config["outdir"] = "."
    if args.outdir:
        config["outdir"] = args.outdir

    if args.verbose:
        config["loglevel"] = logging.INFO

    if args.cloud:
        config["cloud"] = args.cloud

    return config


def do_read_config(config):
    """reads from the config file if present"""
    try:
        with open(config["config_file"], "r", encoding="utf-8") as file:
            newconfig = json.load(file)
            config.update(newconfig)
    except IOError:
        return


def get_data(config):
    """Gets the data from OpenStack using the openstacksdk"""
    openstack_connection = openstack.connect(cloud=config["cloud"])

    hyper_visors = []
    hv_status = {}

    for node in openstack_connection.compute.hypervisors(details=True):
        hv_rec = {}
        hv_rec["id"] = node.id
        hv_rec["hypervisor_hostname"] = node.name
        hv_rec["vcpus"] = node.vcpus
        hv_rec["memory_mb"] = node.memory_size
        hyper_visors.append(hv_rec)

    hv_status["hypervisors"] = hyper_visors
    time_stamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    hv_status["ts"] = time_stamp
    return hv_status


def get_latest_facts(config):
    """gets the previously recorded hypervisor facts"""
    file_list = glob.glob(config["outdir"] + "//hypervisor_facts_*.json")

    if len(file_list) == 0:
        return {"hypervisors": []}

    newest = max(
        file_list,
        key=lambda d: datetime.datetime.strptime(
            d, f"{config['outdir']}/hypervisor_facts_%Y-%m-%dT%H:%M:%S.json"
        ),
    )

    with open(newest, "r", encoding="utf-8") as file:
        latest_facts = json.load(file)

    return latest_facts


def is_new_data(config, data):
    """Checks to see if the hypervisor facts have changed"""
    latest_facts = get_latest_facts(config)
    if deep_compare(latest_facts["hypervisors"]) == deep_compare(data["hypervisors"]):
        logging.info("No new facts found")
        return False
    logging.info("New facts found")
    return True


def main():
    """the main function"""
    config = {}

    do_parse_args(config)
    do_read_config(config)

    logging.basicConfig(
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        level=config["loglevel"],
    )

    data = get_data(config)

    if is_new_data(config, data):
        nowtime = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S")
        json_out = f"{config['outdir']}/hypervisor_facts_{nowtime}.json"
        with open(json_out, "w", encoding="utf-8") as outfile:
            json.dump(data, outfile, indent=2, sort_keys=True)


if __name__ == "__main__":
    main()
