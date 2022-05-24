#!/usr/bin/python3
""" This is intended to poll openstack for changes to be reported in xdmod """
# pylint: disable=line-too-long

import json
import argparse
import logging
import datetime
import re
import openstack
import copy
import os
from novaclient import client as nova_client
from cinderclient import client as cinder_client
from keystoneclient import client as keystone_client
import pprint


# This is the mapping from xdmod of the openstack events that they
# handle to the native xdmod event types
event_types = [
    ["openstack_event_type_id", "event_type_id", "openstack_event_type"],
    [-1, -1, "unknown"],
    [1, 1, "compute.instance.create.start"],
    [2, 2, "compute.instance.create.end"],
    [3, 3, "compute.instance.shutdown.start"],
    [4, 4, "compute.instance.shutdown.end"],
    [5, 5, "compute.instance.delete.start"],
    [6, 6, "compute.instance.delete.end"],
    [7, 10, "compute.instance.volume.attach"],
    [8, 11, "volume.attach.end"],
    [9, 12, "compute.instance.volume.detach"],
    [10, 16, "compute.instance.exists"],
    [11, 19, "compute.instance.shelve_offload.end"],
    [12, 21, "volume.detach.start"],
    [13, 22, "volume.detach.end"],
    [14, 23, "volume.create.start"],
    [15, 24, "volume.create.end"],
    [16, 25, "volume.update.start"],
    [17, 26, "volume.update.end"],
    [18, 27, "volume.attach.start"],
    [19, 28, "volume.delete.start"],
    [20, 29, "volume.delete.end"],
    [21, 30, "volume_type.create"],
    [23, 31, "image.activate"],
    [24, 32, "image.create"],
    [25, 33, "image.delete"],
    [26, 34, "image.prepare"],
    [27, 35, "image.update"],
    [28, 36, "image.upload"],
    [29, 37, "snapshot.create.start"],
    [30, 38, "snapshot.create.end"],
    [31, 39, "snapshot.delete.start"],
    [32, 40, "snapshot.delete.end"],
    [33, 41, "compute.instance.create.error"],
    [34, 42, "compute.instance.finish_resize.start"],
    [35, 43, "compute.instance.finish_resize.end"],
    [36, 44, "compute.instance.power_off.start"],
    [37, 45, "compute.instance.power_off.end"],
    [38, 46, "compute.instance.rebuild.start"],
    [39, 47, "compute.instance.rebuild.end"],
    [40, 48, "compute.instance.resize.confirm.start"],
    [41, 49, "compute.instance.resize.confirm.end"],
    [42, 50, "compute.instance.resize.start"],
    [43, 51, "compute.instance.resize.end"],
    [44, 52, "compute.instance.resize.prep.start"],
    [45, 53, "compute.instance.resize.prep.end"],
    [46, 64, "compute.instance.shelve_offload.start"],
    [47, 7, "compute.instance.resume.start"],
    [48, 8, "compute.instance.resume.end"],
    [49, 58, "compute.instance.power_on.start"],
    [50, 59, "compute.instance.power_on.end"],
    [51, 20, "compute.instance.unshelve.end"],
    [52, 57, "compute.instance.unpause.end"],
    [53, 61, "compute.instance.unsuspend.end"],
    [54, 17, "compute.instance.suspend.end"],
    [55, 55, "compute.instance.pause.end"],
    [56, 62, "compute.instance.suspend.start"],
    [57, 60, "compute.instance.unsuspend.start"],
    [58, 56, "compute.instance.unpause.start"],
    [59, 63, "compute.instance.unshelve.start"],
    [60, 54, "compute.instance.pause.start"],
]


# kaizen-admin server list --all-projects
# | ID                                   | Name       | Status | Networks                                                                          | Image                                            | Flavor                  |
# +--------------------------------------+------------+--------+-----------------------------------------------------------------------------------+--------------------------------------------------+-------------------------+
# | ef56ed6d-86f2-4a05-8fc1-8295c6cfd351 | CS551-Lab  | ACTIVE | default_network=10.0.0.225, 128.31.26.144                                         | N/A (booted from volume)                         | custom.8c.32g           |
# | 03063042-40de-4aae-8625-9455ffec7ff7 | macvitis   | ACTIVE | default_network=10.0.0.34, 128.31.26.241                                          | N/A (booted from volume)                         | c1.xlarge               |
#
# kaizen-admin server event list ab01d0a1-d234-465d-a2eb-f9e7fc507153
# +------------------------------------------+--------------------------------------+----------------+----------------------------+
# | Request ID                               | Server ID                            | Action         | Start Time                 |
# +------------------------------------------+--------------------------------------+----------------+----------------------------+
# | req-80e77822-fa66-4e5c-bd53-90dd16a84fff | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | start          | 2021-08-11T19:38:42.000000 |
# | req-ec74034b-90c2-4839-a4cf-f12bfc4e24fe | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | stop           | 2021-08-09T17:38:45.000000 |
# | req-9931842c-30ac-4918-9ff1-3d6cc40d7375 | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2021-07-15T19:03:21.000000 |
# | req-2fe85009-c54b-4730-a1dc-da7dad4ea72a | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | start          | 2020-10-21T18:57:55.000000 |
# | req-0b79359b-7040-49d8-ac36-768fe9d7a960 | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | stop           | 2020-10-19T14:08:56.000000 |
# | req-c28d7bf2-740c-470b-b5ef-bd80af550b78 | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2020-07-01T13:11:18.000000 |
# | req-b6257c5b-f7c8-4454-9c3e-33b9ee36b0df | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2020-06-18T11:41:33.000000 |
# | req-a1bc6dc2-7ef3-4e35-aa79-bf7ccf8d3acf | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2020-03-06T20:19:38.000000 |
# | req-71286353-a8a8-49ed-9803-92485ae0fe45 | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2020-03-06T17:24:15.000000 |
# | req-4af9f028-3e3f-40f7-8eac-8ce3775713de | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2020-03-02T21:34:00.000000 |
# | req-5a797da9-a1fd-4ee4-ae3a-db70ab1b8ef2 | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2020-03-02T19:59:46.000000 |
# | req-fc66a5fe-48ce-4903-8528-7b143c165d91 | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2019-10-14T22:43:57.000000 |
# | req-61a9e749-2b89-4f27-9e77-e2007fb4eedb | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2019-10-14T22:33:35.000000 |
# | req-c9d0990f-cda3-4e7f-a7b2-66d8078fec6f | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2019-10-14T22:20:16.000000 |
# | req-67dc9878-a1c7-40bc-a059-cfc3679ba938 | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2019-10-14T22:06:13.000000 |
# | req-1255f7c6-b930-4bbf-9779-35065d4f2687 | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | live-migration | 2019-08-23T18:31:32.000000 |
# | req-a78299ae-f258-4887-85fa-1161ef0c13f8 | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | start          | 2019-06-14T01:02:29.000000 |
# | req-5c486a20-2c86-40ef-b70b-079348898258 | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | stop           | 2019-06-10T15:10:27.000000 |
# | req-278cfd18-dd01-4d79-975b-3a115806f1ba | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | attach_volume  | 2019-01-12T17:21:47.000000 |
# | req-37e43e39-324a-4577-8334-a8f8bb6ea5ac | ab01d0a1-d234-465d-a2eb-f9e7fc507153 | create         | 2019-01-11T19:08:38.000000 |
# +------------------------------------------+--------------------------------------+----------------+----------------------------+
#
# kaizen-admin server event show ab01d0a1-d234-465d-a2eb-f9e7fc507153 req-80e77822-fa66-4e5c-bd53-90dd16a84fff
# +---------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
# | Field         | Value                                                                                                                                                                  |
# +---------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
# | action        | start                                                                                                                                                                  |
# | events        | [{'finish_time': '2021-08-11T19:38:45.000000', 'start_time': '2021-08-11T19:38:43.000000', 'traceback': None, 'event': 'compute_start_instance', 'result': 'Success'}] |
# | instance_uuid | ab01d0a1-d234-465d-a2eb-f9e7fc507153                                                                                                                                   |
# | message       | None                                                                                                                                                                   |
# | project_id    | 59d515f823184442a96de3b976c7dcf1                                                                                                                                       |
# | request_id    | req-80e77822-fa66-4e5c-bd53-90dd16a84fff                                                                                                                               |
# | start_time    | 2021-08-11T19:38:42.000000                                                                                                                                             |
# | user_id       | dee87477683645cb8ca4c2963b950e7e                                                                                                                                       |
# +---------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------+


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

    config["end"] = datetime.datetime.utcnow().isoformat()
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
            "cpu": str(vm.vcpus),  # Number of CPU's the instance has,
            "memory": str(vm.ram),  # Amount of memory the instance has,
            "disk": str(vm.disk),  # Amount of storage space in GB this instance has,
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
    vm_volumes = getattr(vm, "os-extended-volumes:volumes_attached", [])
    for volume_id in vm_volumes:
        vol = volume[volume_id["id"]]
        vol_project_id = ""
        vol_project_id = getattr(vol, "os-vol-tenant-attr:tenant_id", [])
        backing = ""
        backing = getattr(vol, "os-vol-host-attr:host", [])
        volume_data = {
            "account": vol_project_id,  # "Account that the storage device belongs to",
            "attach_time": "",  # "Time that the storage device was attached to this instance",
            "backing": backing,  # "type of storage used for this block device, either ebs or instance-store",
            "create_time": vol.created_at,  # "Time the storage device was created",
            "user": vol.user_id,  # "User that the storage device was created by",
            "id": vol.id,  # "ID of the storage volume",
            "size": str(vol.size),  # "Size in GB of the storage volume"
        }
        event_item["block_devices"].append(volume_data)

    return event_item


# 'compute.instance.create.error': 1,
# 'compute.instance.create.start': 1,
# 'compute.instance.shutdown.end': 1,
# 'compute.instance.shutdown.start'
# {
#     "disk_gb": "20",
#     "domain": "Default",
#     "ephemeral_gb": "0",
#     "event_type": "compute.instance.create.start",
#     "generated": "2018-04-18T14:58:38.977823",
#     "host": "srv-p24-33.cbls.ccr.buffalo.edu",
#     "instance_id": "703608ed-0b5c-4968-ba93-30f081bf7aec",
#     "instance_type": "c1.m4",
#     "instance_type_id": "9",
#     "memory_mb": "4096",
#     "message_id": "6e237402-fbae-4af9-bc18-76db88c3706b",
#     "project_id": "4aeb007a4f9020333a1a1be224bef276",
#     "project_name": "zealous",
#     "raw": {},
#     "request_id": "req-0e8a4b00-b47b-4e68-855d-c13a2bb44032",
#     "resource_id": "703608ed-0b5c-4968-ba93-30f081bf7aec",
#     "root_gb": "20",
#     "service": "compute",
#     "state": "building",
#     "tenant_id": "4aeb007a4f9020333a1a1be224bef276",
#     "user_id": "3abcb51ff942a45b52ac90915ef4c7fb",
#     "user_name": "yerwa",
#     "vcpus": "1",
# }

# compute.instance.create.end': 1,
# compute.instance.delete.start': 1,
# compute.instance.live_migration._post.end': 1,
# compute.instance.live_migration._post.start': 1,
# compute.instance.live_migration.post.dest.end': 1,
# compute.instance.live_migration.post.dest.start': 1,
# compute.instance.live_migration.pre.end': 1,
# compute.instance.live_migration.pre.start': 1,
# compute.instance.power_off.end': 1,
# compute.instance.power_off.start': 1,
# compute.instance.power_on.end': 1,
# compute.instance.power_on.start': 1,
# compute.instance.shutdown.end': 1,
# compute.instance.shutdown.start
# {
#     "disk_gb": "20",
#     "domain": "Default",
#     "ephemeral_gb": "0",
#     "event_type": "compute.instance.create.end",
#     "generated": "2018-04-18T14:58:45.774847",
#     "host": "srv-p24-33.cbls.ccr.buffalo.edu",
#     "instance_id": "703608ed-0b5c-4968-ba93-30f081bf7aec",
#     "instance_type": "c1.m4",
#     "instance_type_id": "9",
#     "launched_at": "2018-04-18T14:58:45.685846",
#     "memory_mb": "4096",
#     "message_id": "135a80e4-355f-4561-9c60-e0d2c184e2c3",
#     "project_id": "4aeb007a4f9020333a1a1be224bef276",
#     "project_name": "zealous",
#     "raw": {},
#     "request_id": "req-0e8a4b00-b47b-4e68-855d-c13a2bb44032",
#     "resource_id": "703608ed-0b5c-4968-ba93-30f081bf7aec",
#     "root_gb": "20",
#     "service": "compute",
#     "state": "active",
#     "tenant_id": "4aeb007a4f9020333a1a1be224bef276",
#     "user_id": "3abcb51ff942a45b52ac90915ef4c7fb",
#     "user_name": "yerwa",
#     "vcpus": "1",
# }


def convert_to_ceilometer_event_types(event):
    map_current_to_old = {
        "compute.instance.stop": "compute.instance.power_off",
        "compute.instance.start": "compute.instance.power_on",
    }

    ceilometer_event_types = {
        # these messages are reported from compute events
        # "compute.instance.live-migration": [""],
        # "compute.instance.detach_volume": [""],
        # "compute.instance.stop": [""],
        # "compute.instance.start": [""],
        # "compute.instance.attach_volume": [""],
        # "compute.instance.reboot": [""],
        # "compute.instance.createImage": [""],
        # "compute.instance.confirmResize": [""],
        # "compute.instance.migrate": [""],
        # "compute.instance.resume": [""],
        # "compute.instance.suspend": [""],
        # "compute.instance.unshelve": [""],
        # "compute.instance.shelve": [""],
        # "compute.instance.unpause": [""],
        # "compute.instance.pause": [""],
        # "compute.instance.evacuate": [""],
        # "compute.instance.attach_interface": [""],
        # "compute.instance.unlock": [""],
        # "compute.instance.lock": [""],
        # "compute.instance.detach_interface": [""],
        # "compute.instance.rebuild": [""],
        # "compute.instance.resize": [""],
        # These events are from the reference file
        "compute.instance.create": ["start", "end"],
        "compute.instance.delete": ["start", "end"],  # does this one have a "end"?
        # "compute.instance.live_migration._post": ["start", "end"],
        # "compute.instance.live_migration.post.dest": ["start", "end"],
        # "compute.instance.live_migration.pre": ["start", "end"],
        # "compute.instance.power_off": ["start", "end"],
        # "compute.instance.power_on": ["start", "end"],
        # "compute.instance.shutdown": ["start", "end"],
    }
    if event["event_type"] == "compute.instance.create" and event["state"] == "ERROR":
        event["event_type"] = "compute.instance.create.error"
        return [event]
    if event["event_type"] in map_current_to_old:
        event["event_type"] = map_current_to_old[event["event_type"]]
    if event["event_type"] in ceilometer_event_types:
        ret_list = []
        delta_time = 0
        time_0 = datetime.datetime.fromisoformat(event["generated"])
        for e in ceilometer_event_types[event["event_type"]]:
            new_event = copy.deepcopy(event)
            new_event["event_type"] = f"{new_event['event_type']}.{e}"
            new_event["generated"] = (time_0 + datetime.timedelta(seconds=delta_time)).isoformat()
            ret_list.append(new_event)
            delta_time += 10
        return ret_list
    return []


def compile_server_state(server, project_dict, flavor_dict, user_dict):
    """This one is implied.  We can tell this from the state of the VM"""
    launched_ts = None
    launched_ts = getattr(server, "OS-SRV-USG:launched_at", "")
    host = None
    host = getattr(server, "OS-EXT-SRV-ATTR:host", None)
    terminated_ts = None
    terminated_ts = getattr(server, "OS-SRV-USG:terminated_at", "")
    user_name = "unknown user"
    if server.user_id in user_dict:
        user_name = user_dict[server.user_id]["name"]

    # I am including all of the commented out fields just to document the entire compute structure
    # in one spot.
    server_state = {
        # "audit_period_beginning": start_ts,   --- only add for compute.instance.exists (either active or deleted)
        # "audit_period_ending": "end_ts",
        "disk_gb": str(flavor_dict[server.flavor["id"]]["disk"]),
        "domain": project_dict[server.tenant_id]["domain_id"],
        "ephemeral_gb": str(flavor_dict[server.flavor["id"]]["ephemeral"]),
        # These 2 are filled out below
        # "event_type": event_type,
        # "generated": end_ts,
        "host": host,
        "instance_id": server.id,
        "instance_type": flavor_dict[server.flavor["id"]]["name"],
        # what this should be
        #   "instance_type_id": server.flavor["id"],
        # what xdmod is expecting:
        "instance_type_id": "9",
        "launched_at": launched_ts,
        # "deleted_at": terminated_ts,
        "memory_mb": str(flavor_dict[server.flavor["id"]]["ram"]),
        # Probably unknowable - I suspect this is what ceilometer adds.
        # "message_id": "17d6645e-90f9-481e-9751-f8ec3b9397a2",
        "project_id": server.tenant_id,
        "project_name": project_dict[server.tenant_id]["name"],
        "raw": {},
        # request_id can be NULL
        # "request_id": "req-00b3079e-8cb1-4e63-aa6f-f96fcbd4771c",
        # For compute evens, resource_id is the instance id
        "resource_id": server.id,
        "root_gb": str(flavor_dict[server.flavor["id"]]["disk"]),
        "service": "compute",
        "state": server.status,
        "tenant_id": server.tenant_id,
        "user_id": server.user_id,
        "user_name": user_name,
        "vcpus": str(flavor_dict[server.flavor["id"]]["vcpus"]),
    }
    if terminated_ts is not None:
        server_state["deleted_at"] = terminated_ts
    return server_state


def build_event(server_state, event):
    server_event = copy.deepcopy(server_state)
    if event["event_type"] == "compute.instance.exists":
        server_event["audit_period_beginning"] = copy.copy(event["audit_period_start"])
        server_event["audit_period_ending"] = copy.copy(event["audit_period_end"])
    server_event["event_type"] = copy.copy(event["event_type"])
    server_event["generated"] = copy.copy(event["event_time"])
    return server_event


def main():
    """The main function"""
    config = {}

    do_parse_args(config)
    do_read_config(config)
    if "cloud" in config:
        openstack_conn = openstack.connect(cloud=config["cloud"])
    else:
        print("Please specify an OpenStack cloud using --cloud <cloud name> ")
        exit()
    openstack_nova = nova_client.Client(2, session=openstack_conn.session)
    openstack_cinder = cinder_client.Client(3, session=openstack_conn.session)

    script_timestamp = config["end"]
    script_datetime = datetime.datetime.fromisoformat(script_timestamp)
    last_run_timestamp = None
    vm_timestamps = {}
    try:
        with open("vm_last_report_time.json", "r", encoding="utf-8") as file:
            reporting_state = json.load(file)
        vm_timestamps = reporting_state.vm_timestamps
        last_run_timestamp = reporting_state.last_run_timestamp
    except IOError:
        pass
    except ValueError:
        # Ignore badly formatted file or empty file
        pass

    # so that we can tell if the VM not present
    for vm in vm_timestamps.values():
        vm["updated"] = 0

    flavor_dict = {}
    for flavor in openstack_conn.list_flavors():
        flavor_dict[flavor.id] = flavor

    user_dict = {}
    for user in openstack_conn.list_users():
        user_dict[user.id] = user

    project_dict = {}
    for project in openstack_conn.list_projects():
        project_dict[project.id] = project

    volume_dict = {}
    for volume in openstack_cinder.volumes.list(search_opts={"all_tenants": True}, detailed=True):
        volume_dict[volume.id] = volume

    events = []
    server_dict = {}
    min_event_time = script_datetime
    for server in openstack_nova.servers.list(search_opts={"all_tenants": True}, detailed=True):
        server_dict[server.id] = compile_server_state(server, project_dict, flavor_dict, user)
        server_t = datetime.datetime.strptime(server.created, "%Y-%m-%dT%H:%M:%SZ")

        if server_t < min_event_time:
            min_event_time = server_t
        if server.id in vm_timestamps:
            event_data["start_ts"] = vm_timestamps[server.id]

    if not last_run_timestamp:
        last_run_timestamp = min_event_time.isoformat()
    last_run_datetime = datetime.datetime.fromisoformat(last_run_timestamp)

    events_by_date = {}
    for server_id, server in server_dict.items():
        # need to generate an exitance event for each server in server_dict
        if server["state"] == "ACTIVE" or server["state"] == "DELETED":
            event_data = {
                "audit_period_start": server["launched_at"],
                "audit_period_end": script_timestamp,
                "start_ts": server["launched_at"],
                "event_type": "compute.instance.exists",
                "event_time": script_timestamp,
            }
            event_timestamp = script_datetime.replace(hour=0, minute=0, second=0).isoformat()
            if event_timestamp not in events_by_date:
                events_by_date[event_timestamp] = []
            events_by_date[event_timestamp].append(build_event(server, event_data))

        # I'm getting a error with this statement
        # openstack_event_list = openstack_nova.instance_action.list(server_id, changes_since=last_run_timestamp, changes_before=script_timestamp)
        openstack_event_list = openstack_nova.instance_action.list(server_id)
        for event in openstack_event_list:
            event_time = datetime.datetime.fromisoformat(event.start_time)
            if last_run_datetime <= event_time and event_time < script_datetime:
                event_data = {
                    "audit_period_start": last_run_timestamp,
                    "audit_period_end": script_timestamp,
                    "event_type": f"compute.instance.{event.action}",
                    "event_time": event.start_time,
                    "request_id": event.request_id,  # not certain if this is meaningful or that this is the request id xdmod is expecting
                }
                event_list = convert_to_ceilometer_event_types(build_event(server, event_data))

                for e in event_list:
                    event_timestamp = datetime.datetime.fromisoformat(e["generated"]).replace(hour=0, minute=0, second=0).isoformat()
                    if event_timestamp not in events_by_date:
                        events_by_date[event_timestamp] = []
                    events_by_date[event_timestamp].append(e)

        if server_id not in vm_timestamps:
            vm_timestamps[server_id] = {}
        vm_timestamps[server_id]["timestamp"] = event_data["event_time"]
        vm_timestamps[server_id]["updated"] = 1

        if server["state"] == "DELETED":
            del vm_timestamps[server.id]

    script_file_datetime = script_datetime.replace(hour=0, minute=0, second=0).isoformat()
    for d1, daily_events in events_by_date.items():
        if d1 < script_file_datetime:
            d2 = (datetime.datetime.fromisoformat(d1) + datetime.timedelta(days=1)).isoformat()
            json_out = f"{config['outdir']}/{d1}_{d2}.json"
        else:
            json_out = "CurrentEventsFile.json"
        with open(json_out, "w+", encoding="utf-8") as outfile:
            json.dump(daily_events, outfile, indent=2, sort_keys=True, separators=(",", ": "))
        print(f"output file: {json_out}")

    vm_keys = vm_timestamps.keys()
    for key in vm_keys:
        if vm_timestamps[key]["updated"] == 0:
            del vm_timestamps[key]
        else:
            del vm_timestamps[key]["updated"]

    with open("hiearchy.csv", "w+", encoding="utf-8") as file:
        for user in user_dict:
            json.dump(user_dict, file)

    api_reporting_state = {"last_run_timestamp": last_run_timestamp, "vm_timestamps": vm_timestamps}
    with open("last_report_time.json", "w+", encoding="utf-8") as file:
        json.dump(api_reporting_state, file)


if __name__ == "__main__":
    main()
