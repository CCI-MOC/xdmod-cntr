#!/usr/bin/python3
""" This is intended to poll openstack for changes to be reported in xdmod """
# pylint: disable=line-too-long too-many-locals

import json
import argparse
import logging
import datetime
import openstack
from novaclient import client as nova_client
from cinderclient import client as cinder_client


def do_parse_args(config):
    """Parse args and return a config dict"""
    parser = argparse.ArgumentParser(description="Generate accounting records for OpenStack instances", epilog="-D and -A are mutually exclusive")
    parser.add_argument("-v", "--verbose", help="output debugging information", action="store_true")
    parser.add_argument("-n", "--nostate", help="Skip state messages", action="store_true")
    parser.add_argument("-c", "--collapse-traits", help="Collapse the traits array to the top level", action="store_true")
    parser.add_argument("-C", "--config-dir", help="Configuration directory")
    parser.add_argument("-s", "--start", help="Start time for records", required=False)  # pulls the time of the event from the event list
    parser.add_argument("-e", "--end", help="End time for records", required=False)  # defaults to current time
    parser.add_argument("-o", "--outdir", help="Output directory")
    parser.add_argument("--cloud", help="Using the name/credentials in the cloud config file to connect with OpenStack")
    parser.add_argument("-d", "--db", help="Database name, only valid for --use-db")
    parser.add_argument("-f", "--filter-noise", help="Filter out noisy events. Requires panko patch", action="store_true")

    args = parser.parse_args()

    config["loglevel"] = logging.CRITICAL

    if args.collapse_traits:
        config["collapse_traits"] = True

    if args.filter_noise:
        config["filter_noise"] = True

    if args.cloud:
        config["cloud"] = args.cloud

    config["config_dir"] = "."
    if args.config_dir:
        config["config_dir"] = args.config_file

    config["start"] = None
    if args.start:
        config["start"] = args.start

    config["end"] = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S")
    if args.end:
        config["end"] = args.end

    config["outdir"] = "."
    if args.outdir:
        config["outdir"] = args.outdir

    if args.verbose:
        config["loglevel"] = logging.WARNING

    if args.nostate:
        config["nostate"] = True
        config["skip_events"].append("compute.instance.exists")

    return config


def do_read_config(config):
    """reads from the config file if present"""
    try:
        with open(f"{config['config_dir']}/openstack_reporting.json", "r", encoding="utf-8") as config_fp:
            newconfig = json.load(config_fp)
            config.update(newconfig)
    except IOError:
        return
    except ValueError:
        print("Error, Badly formatted config file")
        exit()


def build_event_item(event, vm, volume):
    """Builds the event record from the vm and volume data"""
    # just grab the first network from the addresses
    network_interfaces = len(vm.addresses)
    private_ip = ""
    if network_interfaces > 0:
        network = list(vm.addresses.keys())[0]
        if len(vm.addresses[network]) > 0:
            private_ip = vm.addresses[network][0]["addr"]

    event_item = {
        "node_controller": vm.hostId,  # IP address of node controller   -- is it better to use the host id?
        "public_ip": "",  # Publically available IP address,  -- empty for now
        "account": vm.tenant_id,  # Account that user is logged into,  -- using the instant's project id (could the event project id be different?)
        "event_type": event.action,  # Type of event,
        "event_time": event.start_time,  # Time that event happened,
        "instance_type": {
            "name": vm.id,  # Name of VM,   --  the instance id
            "cpu": vm.vcpus,  # Number of CPU's the instance has,
            "memory": vm.ram,  # Amount of memory the instance has,
            "disk": vm.disk,  # Amount of storage space in GB this instance has,
            "networkInterfaces": network_interfaces,  # Number of network interfaces
        },
        "image_type": vm.image,  # Name of the type of image this instance uses,
        "instance_id": vm.id,  # ID for the VM instance,
        "record_type": "",  # Type of record from list in modw_cloud.record_type table,
        "block_devices": [],
        "private_ip": private_ip,  # "Private IP address used by the instance,
        "root_type": "",  # "Type of storage initial storage volume is, either ebs or instance-store
    }

    vm_volumes = []
    if "os-extended-volumes:volumes_attached" in vm.to_dict():
        vm_volumes = vm.__getattribute__("os-extended-volumes:volumes_attached")
    for volume_id in vm_volumes:
        vol = volume[volume_id["id"]]
        vol_project_id = ""
        if "os-vol-tenant-attr:tenant_id" in vol.to_dict():
            vol_project_id = vol.__getattribute__("os-vol-tenant-attr:tenant_id")
        backing = ""
        if "os-vol-host-attr:host" in vol.to_dict():
            backing = vol.__getattribute__("os-vol-host-attr:host")
        volume_data = {
            "account": vol_project_id,  # "Account that the storage device belongs to",
            "attach_time": "",  # "Time that the storage device was attached to this instance",
            "backing": backing,  # "type of storage used for this block device, either ebs or instance-store",
            "create_time": vol.created_at,  # "Time the storage device was created",
            "user": vol.user_id,  # "User that the storage device was created by",
            "id": vol.id,  # "ID of the storage volume",
            "size": vol.size,  # "Size in GB of the storage volume"
        }
        event_item["block_devices"].append(volume_data)

    return event_item


def main():
    """The main function"""
    config = {}

    do_parse_args(config)
    do_read_config(config)

    openstack_conn = openstack.connect(cloud="admin-kaizen")
    openstack_nova = nova_client.Client(2, session=openstack_conn.session)
    openstack_cinder = cinder_client.Client(3, session=openstack_conn.session)

    script_timestamp = config["end"]
    vm_timestamps = {}
    try:
        with open("vm_last_report_time.json", "r", encoding="utf-8") as file:
            vm_timestamps = json.load(file)
    except IOError:
        pass
    except ValueError:
        # Ignore badly formatted file or empty file
        # note, this file can be empty (if no vms are running)
        pass
    # so that we can tell if the VM still exists
    for vm in vm_timestamps.values():
        vm["updated"] = 0

    flavor_dict = {}
    for flavor in openstack_conn.list_flavors():
        flavor_dict[flavor.id] = flavor

    user_dict = {}
    for user in openstack_conn.list_users():
        user_dict[user.id] = user

    volume_dict = {}
    for volume in openstack_cinder.volumes.list(search_opts={"all_tenants": True}, detailed=True):
        volume_dict[volume.id] = volume

    server_dict = {}
    for server in openstack_nova.servers.list(search_opts={"all_tenants": True}, detailed=True):
        server.disk = flavor_dict[server.flavor["id"]]["disk"]
        server.ram = flavor_dict[server.flavor["id"]]["ram"]
        server.vcpus = flavor_dict[server.flavor["id"]]["vcpus"]
        server_dict[server.id] = server

    events = []
    for server_id, server in server_dict.items():
        last_timestamp = None
        if config["start"]:
            last_timestamp = config["start"]
        elif server_id in vm_timestamps:
            last_timestamp = vm_timestamps[server_id]["timestamp"]

        # Only get the data since we last ran the script
        # event_list = openstack_nova.instance_action.list(server_id, changes_since=last_timestamp, changes_before=script_timestamp)
        # event_list = openstack_nova.instance_action.list(server_id, changes_since=None, changes_before=None)
        event_list = openstack_nova.instance_action.list(server_id)
        for event in event_list:
            event_data = build_event_item(event, server, volume_dict)
            events.append(event_data)
            if server_id not in vm_timestamps:
                vm_timestamps[server_id] = {}
            vm_timestamps[server_id]["timestamp"] = event_data["event_time"]
            vm_timestamps[server_id]["updated"] = 1

    json_out = f"{config['outdir']}/cloud_reporting_{script_timestamp}.json"
    with open(json_out, "w+", encoding="utf-8") as outfile:
        json.dump(events, outfile, indent=2, sort_keys=True, separators=(",", ": "))

    for key, val in vm_timestamps.items():
        if val["updated"] == 0:
            del vm_timestamps[key]
        else:
            del vm_timestamps[key]["updated"]

    with open("vm_last_report_time.json", "w+", encoding="utf-8") as file:
        json.dump(vm_timestamps, file)


if __name__ == "__main__":
    main()
