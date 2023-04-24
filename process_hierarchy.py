#!/usr/local/bin/python3
""" This pulls the config files from the database and copies them in to /etc/xdmod

    Will be unnecessary if RWX volumes become available
"""
# pylint: disable=line-too-long invalid-name
import os
import subprocess
import json
import pprint
import copy
import mysql.connector
import hashlib
import moc_db_helper_functions


def get_data_from_coldfront():
    """This fetches the allocation data from coldfront with the format of:
    [
    {
        "id": <num>,                      # coldfront allocation id
        "project": {
            "id": <num>,                  # coldfront project id
            "title": <str>,               # colfront project title
            "pi": "willjt@bu.edu",        # principle investigator
            "description": <str>,         # coldfront project description
            "field_of_science": <str>,    # coldfront project field of science
            "status": "New"               # coldfront project status, ("New", ...)
        },
        "description": "",                # coldfront allocation
        "resource": {
            "name": "NERC-OCP",           # coldfront allocation resource
            "resource_type": "OpenShift"  # coldfront allocation resource type
        },
        "status": "Active",               # coldfront allocation status
        "attributes": {
            "Allocated Project ID": str,  # rosource specific project id
            "Allocated Project Name": str # resource specific project name
        }
    },
    ...
    ]

    """
    with open("../coldfront_data.json") as coldfront_file:
        data = json.load(coldfront_file)
        return data
    return None


def get_data():
    with open("../hierarchy_data.json") as hierarchy_file:
        data = json.load(hierarchy_file)
        for rec in data:
            rec["status"] = "Active"
        return data
    return None


def create_hierarchy_db(cursor):
    cursor.execute("create database hierarchy_db", None)
    cursor.execute(
        "create table hierarchy_db.hierarchy_rec ( \
            id varchar(256) autoincrement, \
            create_ts timestamp, \
            type varchar(100) not null, \
            name varchar(500) not null, \
            status varchar(100), \
            display_name varchar(500), \
            parent_id varchar(256), \
            primary key (id, create_ts) \
        )",
        None,
    )
    # The sha256 field is a compsite key based on all
    cursor.execute(
        "create table hierarchy_db.hierarchy_keys ( \
            root_level_id bigint not null, \
            mid_level_id bigint, \
            bottome_level_id bigint, \
            sha256 varchar(32) \
        )",
        None,
    )


def delete_hierarchy_db(cursor):
    if db_exist(cursor, "hierarchy_db"):
        cursor.execute("drop database hierarchy_db", None)


def add_record(cursor, rec, current_dict):
    # check to see if record exists
    current_rec = find(rec["name"], current_dict)
    # add new record if different
    # craft a unique id
    cursor.execute(
        "insert into hierarchy_db.hierarchy_rec ( \
        id, \
        create_ts, \
        type, \
        name, \
        status, \
        display_name, \
        parent_id \
        ) values ( \
        %(cold_front_id)s, \
        now(), \
        %(type)s, \
        %(name)s, \
        %(status)s, \
        %(display_name)s, \
        %(parent_cold_front_id)s \
        )",
        {
            "cold_front_id": rec["id"],
            "type": rec["type"],
            "name": rec["abbrev"],
            "display_name": rec["name"],
            "status": rec["status"],
            "parent_cold_front_id": rec["parent_id"],
        },
    )
    return None


def create_dictionary(cursor, sql_stmt, params):
    records = exec_fetchall(cursor, sql_stmt, params)
    ret_dict = {}
    for rec in records:
        ret_dict[rec["id"]] = copy.deepcopy(rec)
    return ret_dict


def create_xdmod_key(high_key, mid_key="", low_key=""):
    m = hashlib.sha256()
    m.update((f"{str(high_key)}+{str(mid_key)}+{str(low_key)}").encode("utf-8"))
    return m.hexdigest()


def create_hierarchy_files(level1, level2, level3, level4, level5):
    # construct hierarchy.csv
    with open("hierarchy.csv", "w") as hierarchy_file:
        for rec_id, rec in level1.items():
            unique_key = create_xdmod_key(rec_id)
            hierarchy_file.write(f"{unique_key},{rec['name']},\n")
        for l2_id, l2 in level2.items():
            unique_key = create_xdmod_key(level1[l2["parent_id"]], l2_id)
            parent_key = create_xdmod_key(l2["parent_id"])
            hierarchy_file.write(f"{unique_key},{l2['name']},{parent_key}\n")
        for l3_id, l3_rec in level3.items():
            unique_key = create_xdmod_key(
                (level2[l3_rec["parent_id"]])["parent_id"], l3_rec["parent_id"], l3_id
            )
            parent_key = create_xdmod_key(
                (level2[l3_rec["parent_id"]])["parent_id"], l3_rec["parent_id"]
            )
            hierarchy_file.write(f"{unique_key},{l3_rec['name']},{parent_key}\n")

    # constrcut groups.csv (level 4 of the hierarchy, though this is a mapping table between pi/group and the hiearachy)
    with open("group.csv", "w") as group_file:
        for l4_id, l4_rec in level4.items():
            l3_rec = level3[l4_rec["parent_id"]]
            unique_key = create_xdmod_key(
                (level2[l3_rec["parent_id"]])["parent_id"],
                l3_rec["parent_id"],
                l3_rec["id"],
            )
            group_file.write(f'"{l4_rec["name"]}", "{unique_key}" \n')

    # constrcut pi2project
    with open("pi2project.csv", "w") as pi2project_file:
        for l5 in level5.values():
            l4_rec = level4[l5["parent_id"]]
            pi2project_file.write(f"{level4[l4_id]['name']}, {l5['name']}\n")
    return


def find(name, dictionary):
    for rec in dictionary.values():
        if name == rec["name"]:
            return rec["id"]
    return None


def main():
    """the main function"""
    config = {"host": "localhost", "xdmod_password": "pass", "admin_password": "pass"}

    # try:
    #    with open("/etc/xdmod/xdmod_init.json", "r", encoding="utf-8") as file:
    #        config = json.load(file)["database"]
    # except IOError:
    #    print("Ensure the xdmod-init.json file is in /etc/xdmod/xdmod_init.json")

    cnx = connect_to_db(config)
    cursor = cnx.cursor(dictionary=True)
    if db_exist(cursor, "hierarchy_db"):
        delete_hierarchy_db(cursor)

    if not db_exist(cursor, "hierarchy_db"):
        create_hierarchy_db(cursor)

    institution_layer = create_dictionary(
        cursor,
        "select * from hierarchy_db.hierarchy_rec hr where hr.type='institution'",
        None,
    )
    fieldOfSci_layer = create_dictionary(
        cursor,
        "select * from hierarchy_db.hierarchy_rec hr where hr.type='field-of-science'",
        None,
    )
    pi_layer = create_dictionary(
        cursor, "select * from hierarchy_db.hierarchy_rec hr where hr.type='pi'", None
    )
    project_layer = create_dictionary(
        cursor,
        "select * from hierarchy_db.hierarchy_rec hr where hr.type='openstack-project' or hr.type='openshift-project'",
        None,
    )
    cloud_project_layer = create_dictionary(
        cursor,
        "select * from hierarchy_db.hierarchy_rec hr where hr.type='openstack-project'",
        None,
    )

    data = get_data()
    for record in data:
        add_record(cursor, record)

    coldfront_data = get_data_from_coldfront()
    for record in coldfront_data:
        pi_id = find(record["project"]["pi"], pi_layer)

        pi_rec = {
            "type": "PI",
            "abbrev": record["project"]["pi"],
            "name": record["project"]["pi"],
            "parent_id": "0",
        }

        add_record(cursor, pi_rec, pi_layer)

        project = {
            "abbrev": record["attributes"]["Allocated Project ID"],
            "name": record["attributes"]["Allocated Project Name"],
            "parent_id": record["project"]["pi"],
        }
        cloud_project()
        if (
            record["resource"]["name"] == "NERC"
            and record["resource"]["resource_type"] == "OpenShift"
        ):
            project["type"] == "openshift-project"
        elif (
            record["resource"]["name"] == "NERC"
            and record["resource"]["resource_type"] == "OpenStack"
        ):
            project["type"] == "openstack-project"

        cloud_project = {}
        add_record(cursor, record)

    # projects is consider tier 4 of this hierarchy, and cloud_projects is lower, so the parent_id of the cloud_projects
    # will point to the id in the projects - which happens to be the same as it's id
    for rec_id, rec in cloud_project_layer.items():
        rec["parent_id"] = rec_id
    cnx.commit()
    cnx.close()

    create_hierarchy_files(
        institution_layer,
        fieldOfSci_layer,
        pi_layer,
        project_layer,
        cloud_project_layer,
    )

    # Now to swap the bottom layer with the project layer
    # 1) point the cloud_project to
    new_bottom_layer = {}
    new_pis = {}
    new_pi_id_count = 0
    for cloud_project in cloud_project_layer.values():
        project_id = cloud_project["parent_id"]
        pi_id = project_layer[project_id]["parent_id"]
        new_bottom_layer[project_id] = copy.copy(project_layer[project_id])
        new_bottom_layer[project_id]["parent_id"] = pi_layer[pi_id]["parent_id"]
        new_pi_id_count = new_pi_id_count + 1
        new_pi_id = pi_layer[pi_id]["name"] + str(new_pi_id_count)
        new_pis[new_pi_id] = copy.copy(pi_layer[pi_id])
        new_pis[new_pi_id]["parent_id"] = project_id
        cloud_project["parent_id"] = new_pi_id

    for project_id, project in project_layer.items():
        if project["type"] == "openshift-project":
            new_bottom_layer[project_id] = copy.copy(project)
            new_bottom_layer[project_id]["parent_id"] = pi_layer[project["parent_id"]][
                "parent_id"
            ]
            new_pi_id_count = new_pi_id_count + 1
            new_pi_id = pi_layer[project["parent_id"]]["name"] + str(new_pi_id_count)
            new_pis[new_pi_id] = copy.copy(pi_layer[project["parent_id"]])
            new_pis[new_pi_id]["parent_id"] = project_id

    # create_hierarchy_files(top_layer, mid_layer, new_bottom_layer, new_pis, cloud_project_layer)


if __name__ == "__main__":
    main()
