#!/usr/local/bin/python3
"""
This processes data from coldfront, keycloak and historic data to
generate the following xdmod files:
    hierarchy.json    - 3 layers institution, field-of-science, pi
    groups.json       - information linking project ids to the pi
    pi2project.json   - this links cloud-projects ids to projects ids
    names.json        - links ids to project names
"""
# pylint: disable=line-too-long invalid-name
import json
import copy
import logging
import hashlib
import os
import sys
import argparse
import moc_db_helper_functions as moc_db
import get_users_from_keycloak as user_data


# from keycloak
#
# This links institution, field-of-science and PI together
#
# expected format:
# [{
#    'access': {
#        'impersonate': True,
#        'manage': True,
#        'manageGroupMembership': True,
#        'mapRoles': True,
#        'view': True
#    },
#    'attributes': {
#        'cilogon_idp_name': ['<institution>'],
#        'mss_research_domain': ['<field-of-science>']
#    },
#    'createdTimestamp': <unix timestamp>,
#    'disableableCredentialTypes': [],
#    'email': '<PI's email>',
#    'emailVerified': True,
#    'enabled': True,
#    'firstName': '<PI's first name>',
#    'id': '<id>',
#    'lastName': '<PI's last name>',
#    'notBefore': 0,
#    'requiredActions': [],
#    'totp': False,
#    'username': '<PI's username>'
#    },
#    ...
# ]
#
# from coldfront:
#
# This links PI with project/cloud_project.
#
# This fetches the allocation data from coldfront with the format of:
# [
# {
#    "id": <num>,                      # coldfront allocation id
#    "project": {
#        "id": <num>,                  # coldfront project id
#        "title": <str>,               # colfront project title
#        "pi": "willjt@bu.edu",        # principle investigator
#        "description": <str>,         # coldfront project description
#        "field_of_science": <str>,    # coldfront project field of science
#        "status": "New"               # coldfront project status, ("New", ...)
#    },
#    "description": "",                # coldfront allocation
#    "resource": {
#        "name": "NERC-OCP",           # coldfront allocation resource
#        "resource_type": "OpenShift"  # coldfront allocation resource type
#    },
#    "status": "Active",               # coldfront allocation status
#    "attributes": {
#        "Allocated Project ID": str,  # rosource specific project id
#        "Allocated Project Name": str # resource specific project name
#    }
# },
# ...
# ]


def get_keycloak_dict(keycloak_info):
    """Processes the keycloak data from a list to a dictionary"""
    allocations = user_data.get_keycloak_data(keycloak_info)
    allocation_dict = {}
    for rec in allocations:
        allocation_dict[rec["email"]] = rec
    return allocation_dict


def create_hierarchy_db(cursor):
    """creates the tables of the hierarchy database"""
    cursor.execute("create database hierarchy_db", None)
    cursor.execute(
        "create table hierarchy_db.hierarchy_rec ( \
            id bigint, \
            create_ts datetime(6), \
            type varchar(100) not null, \
            name varchar(500) not null, \
            status varchar(100), \
            display_name varchar(500), \
            parent_id bigint, \
            primary key (id, create_ts) \
        )",
        None,
    )
    cursor.execute(
        "create sequence hierarchy_db.hierarchy_db_id_seq start with 3 increment by 1;"
    )
    # insert the 2 unknown institution and field-of-science here as opposed to using the data file
    cursor.execute("use hierarchy_db", None)
    cursor.execute(
        "insert into hierarchy_rec ( \
            id, \
            create_ts, \
            type, \
            name, \
            status, \
            display_name, \
            parent_id) values \
            (1, CURRENT_TIMESTAMP(6), 'institution', 'unknown', 'Active', 'Unknown', null ), \
            (2, CURRENT_TIMESTAMP(6), 'field-of-science', 'unknown', 'Active', 'Unknown', 1)",
        None,
    )


def process_record(cursor, rec, current_dict):
    """
    processes the record, by checking if it currently exists

    if it exists:
        use it's current id
        if it is modified add the modification
    else
        add the record

    This way we can keep track of the history in an auditable
    manner
    """
    update = False
    hierarchy_id = find_hierarchy_id(rec["name"], current_dict)
    if hierarchy_id:
        if (
            current_dict[hierarchy_id]["name"] != rec["name"]
            or current_dict[hierarchy_id]["display_name"] != rec["display_name"]
            or current_dict[hierarchy_id]["parent_id"] != rec.get("parent_id")
            or current_dict[hierarchy_id]["status"] != rec.get("status")
        ):
            # update the dictionary
            current_dict[hierarchy_id]["type"] = rec["type"]
            current_dict[hierarchy_id]["name"] = rec["name"]
            current_dict[hierarchy_id]["display_name"] = rec["display_name"]
            current_dict[hierarchy_id]["status"] = rec["status"]
            current_dict[hierarchy_id]["parent_id"] = rec["parent_id"]
            update = True
    else:
        # create a new record with a new id
        cursor.execute("use hierarchy_db")
        hierarchy_id = moc_db.exec_fetchone(
            cursor, "select nextval(hierarchy_db_id_seq) as hierarchy_id", None
        )["hierarchy_id"]
        if not hierarchy_id:
            logging.error("Cannot get hierarchy_id from sequencer")
            sys.exit()
        current_dict[hierarchy_id] = copy.copy(rec)
        current_dict[hierarchy_id]["id"] = hierarchy_id
        update = True
    current_dict[hierarchy_id]["accessed"] = True
    if update:
        cursor.execute("use hierarchy_db")
        cursor.execute(
            "insert into hierarchy_rec ( \
            id, \
            create_ts, \
            type, \
            name, \
            status, \
            display_name, \
            parent_id \
            ) values ( \
            %(id)s, \
            CURRENT_TIMESTAMP(6), \
            %(type)s, \
            %(name)s, \
            %(status)s, \
            %(display_name)s, \
            %(parent_id)s \
            )",
            {
                "id": hierarchy_id,
                "type": rec["type"],
                "name": rec["name"],
                "display_name": rec["display_name"],
                "status": rec["status"],
                "parent_id": rec["parent_id"],
            },
        )


def create_hierarchy_dictionary(cursor, sql_stmt, params):
    """
    This creates a dictionary of the records returned.

    Assuming that the sql places things in chronological order
    this will return a dictionary of the latest record for each id
    """
    records = moc_db.exec_fetchall(cursor, sql_stmt, params)
    return {rec["id"]: rec for rec in records}


def create_xdmod_key(high_key, mid_key="", low_key=""):
    """
    This combines upto 3 keys into a single (shorter) key

    This was done as a general way of building a key from the
    datafields and not assiging it a key (which is what I've wound up
    doing)
    """
    m = hashlib.sha256()
    m.update((f"{str(high_key)}+{str(mid_key)}+{str(low_key)}").encode("utf-8"))
    return m.hexdigest()


def create_hierarchy_files(hierarchy, coldfront2resource):
    """
    This builds the hierarchy files from the data coming from coldfront, keycloak
    and historic data from the database
    """
    # construct hierarchy.csv
    with open("hierarchy.csv", "w", encoding="utf-8") as hierarchy_file:
        for rec_id, rec in hierarchy["institution"].items():
            if rec["status"] == "Active":
                hierarchy_file.write(f'"{rec_id}","{rec["name"]}",\n')
        for l2_id, l2 in hierarchy["field-of-science"].items():
            if l2["status"] == "Active":
                hierarchy_file.write(f'"{l2_id}","{l2["name"]}","{l2["parent_id"]}"\n')
        for l3_id, l3_rec in hierarchy["pi"].items():
            if l3_rec["status"] == "Active":
                hierarchy_file.write(
                    f'"{l3_id}","{l3_rec["display_name"]}","{l3_rec["parent_id"]}"\n'
                )

    # construct groups.csv (level 4 of the hierarchy, though this is a mapping table between pi/group and the hiearachy)
    with open("group.csv", "w", encoding="utf-8") as group_file:
        for l4_id, l4_rec in hierarchy["project"].items():
            if l4_rec["status"] == "Active":
                l3_rec = hierarchy["pi"][l4_rec["parent_id"]]
                group_file.write(f'"{l4_rec["name"]}", "{l4_rec["parent_id"]}"\n')

    # construct pi2project
    with open("pi2project.csv", "w", encoding="utf-8") as pi2project_file:
        for l5 in hierarchy["cloud-project"].values():
            if l5["status"] == "Active":
                l4_rec = hierarchy["project"][l5["parent_id"]]
                l4_id = l4_rec["id"]
                # need to add in a project type ( NERC, openstack ) to resource name ('nerc-ocp-prod')
                pi2project_file.write(
                    f'"{hierarchy["project"][l4_id]["name"]}", "{l5["name"]}", "{coldfront2resource[l4_rec["type"]]["resource_name"]}"\n'
                )

    # construct the names.csv (rename records in the hierarchy)
    with open("names.csv", "w", encoding="utf-8") as name_file:
        for l4_id, l4_rec in hierarchy["project"].items():
            if l4_rec["status"] == "Active":
                name_file.write(f'"{l4_rec["name"]}", , "{l4_rec["display_name"]}"\n')


def find_hierarchy_id(name, dictionary):
    """returns the hierarchy_id if found in the dictionary"""
    for rec_id, rec in dictionary.items():
        if name == rec["name"]:
            dictionary[rec_id]["accessed"] = True
            return rec_id
    return None


def get_hierarchy_from_db(cursor):
    """
    fetch the most recent record for each item in the hierarchy
    """
    hierarchy = {}
    hierarchy["institution"] = create_hierarchy_dictionary(
        cursor,
        "select * from hierarchy_db.hierarchy_rec hr where hr.type='institution' order by hr.create_ts",
        None,
    )
    hierarchy["field-of-science"] = create_hierarchy_dictionary(
        cursor,
        "select * from hierarchy_db.hierarchy_rec hr where hr.type='field-of-science' order by hr.create_ts",
        None,
    )
    hierarchy["pi"] = create_hierarchy_dictionary(
        cursor,
        "select * from hierarchy_db.hierarchy_rec hr where hr.type='pi' order by hr.create_ts",
        None,
    )
    hierarchy["project"] = create_hierarchy_dictionary(
        cursor,
        "select * from hierarchy_db.hierarchy_rec hr where hr.type='openstack-project' or hr.type='openshift-project' order by hr.create_ts",
        None,
    )
    hierarchy["cloud-project"] = create_hierarchy_dictionary(
        cursor,
        "select * from hierarchy_db.hierarchy_rec hr where hr.type='openstack-cloud-project' order by hr.create_ts",
        None,
    )
    return hierarchy


def process_institution(cursor, institution, institution_dict):
    """
    The processes the institution and returns the assigned institution_id
    """
    if institution is None:
        institution = "unknown"
    institution_id = find_hierarchy_id(institution, institution_dict)
    if not institution_id:
        inst_rec = {
            "type": "institution",
            "name": institution,
            "display_name": institution,
            "status": "Active",
            "parent_id": None,
        }
        process_record(cursor, inst_rec, institution_dict)
        institution_id = find_hierarchy_id(institution, institution_dict)
    return institution_id


# pylint: disable=too-many-locals
def process_data(cursor, hierarchy, keycloak_info, coldfront_info):
    """
    This combines the cold front data with the
    """
    keycloak_data = get_keycloak_dict(keycloak_info)
    coldfront_data = user_data.get_coldfront_data(keycloak_info, coldfront_info)
    for record in coldfront_data:
        # nee the PI name to look up the PI meta data from keycloak
        pi_rec = {
            "type": "pi",
            "name": record["project"]["pi"],
            "display_name": record["project"]["pi"],
            "status": "Active",
        }
        pi_id = find_hierarchy_id(pi_rec["name"], hierarchy["pi"])
        if pi_id:
            pi_rec["id"] = pi_id

        keycloak_rec = keycloak_data[pi_rec["name"]]

        # find the pi's field of science - the pi's parent_id
        if keycloak_rec is None:
            pi_rec["parent_id"] = find_hierarchy_id(
                "unknown", hierarchy["field-of-science"]
            )
        else:
            # pick the first element of the list and assume it is the primary one
            #  - can the cilogon_idp_name have either 0 or more th1n 1 elements?
            institution = keycloak_rec["attributes"]["cilogon_idp_name"][0]
            institution_id = process_institution(
                cursor, institution, hierarchy["institution"]
            )
            institution = hierarchy["institution"][institution_id]["name"]

            # here again, pick the first element of the list and assume it is the primary one
            #  - can the mss_research_domain have either 0 or more th1n 1 elements?
            field_of_science = f"{institution} - {keycloak_rec['attributes']['mss_research_domain'][0]}"
            fos_id = find_hierarchy_id(field_of_science, hierarchy["field-of-science"])
            if not fos_id:
                fos_rec = {
                    "type": "field-of-science",
                    "name": field_of_science,
                    "display_name": keycloak_rec["attributes"]["mss_research_domain"][
                        0
                    ],
                    "status": "Active",
                    "parent_id": institution_id,
                }
                process_record(cursor, fos_rec, hierarchy["field-of-science"])
                fos_id = find_hierarchy_id(
                    field_of_science, hierarchy["field-of-science"]
                )

            # now that we know the pi's field of science id (fos_id)
            if fos_id:
                pi_rec["parent_id"] = fos_id
            else:
                pi_rec["parent_id"] = find_hierarchy_id(
                    "Unknown", hierarchy["field-of-science"]
                )

            # add in the pi's name
            pi_rec[
                "display_name"
            ] = f"{keycloak_rec['firstName']} {keycloak_rec['lastName']} <{keycloak_rec['email']}>"
        process_record(cursor, pi_rec, hierarchy["pi"])

        if not pi_id:
            pi_id = find_hierarchy_id(pi_rec["name"], hierarchy["pi"])
            pi_rec = hierarchy["pi"][pi_id]

        project_rec = {
            "name": record["attributes"]["Allocated Project Name"],
            "display_name": f"{record['project']['title']} - {record['attributes']['Allocated Project Name']}",
            "parent_id": pi_id,
            "status": record["status"],
        }
        if not project_rec["name"]:
            project_rec["name"] = project_rec["display_name"]

        if (
            record["resource"]["name"] == "NERC-OCP"
            and record["resource"]["resource_type"] == "OpenShift"
        ):
            project_rec["type"] = "NERC-OCP-OpenShift"
            process_record(cursor, project_rec, hierarchy["project"])
        elif (
            record["resource"]["name"] == "NERC"
            and record["resource"]["resource_type"] == "OpenStack"
        ):
            project_rec["type"] = "NERC-OpenStack"
            process_record(cursor, project_rec, hierarchy["project"])
            project_rec["parent_id"] = find_hierarchy_id(
                project_rec["name"], hierarchy["project"]
            )
            project_rec["type"] = "cloud-project"
            project_rec["id"] = find_hierarchy_id(
                project_rec["name"], hierarchy["cloud-project"]
            )
            process_record(cursor, project_rec, hierarchy["cloud-project"])
        else:
            logging.info("Unknown project_record type %s", json.dumps(record))


def process_inactive(cursor, hierarchy):
    """Marks records in the hierarchy as being inactive if they were not accessed"""
    for level in ["institution", "field-of-science", "pi", "project", "cloud-project"]:
        for rec_id in hierarchy[level]:
            if not hierarchy[level][rec_id].get("accessed", False):
                rec = copy.copy(hierarchy[level][rec_id])
                rec["status"] = "Inactive"
                process_record(cursor, rec, hierarchy[level])


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-directory", required=False)
    args = parser.parse_args()

    arg_dict = {}
    if args.output_directory:
        arg_dict = {"output_directory": args.output_directory}
    return arg_dict


def main():
    """the main function"""

    # read in the xdmod_init.json file to get the database and resource configs
    try:
        with open("/etc/xdmod/xdmod_init.json", "r", encoding="utf-8") as file:
            config = json.load(file)
    except IOError:
        print("Ensure the xdmod-init.json file is in /etc/xdmod/xdmod_init.json")

    cli_args = get_args()
    output_directory = cli_args.get("output_directory", None)
    if output_directory:
        os.chdir(output_directory)

    coldfront2resource = {}
    for resource in config["resource"]:
        if "ColdFront" in resource:
            coldfront2resource[resource["ColdFront"]] = {
                "resource_name": resource["name"],
                "resource_type": resource["type"],
            }

    cnx = moc_db.connect_to_db(config["database"])
    cursor = cnx.cursor(dictionary=True)

    if not moc_db.db_exist(cursor, "hierarchy_db"):
        create_hierarchy_db(cursor)
        cnx.commit()

    hierarchy = get_hierarchy_from_db(cursor)
    process_data(cursor, hierarchy, config["keycloak_info"], config["coldfront_info"])
    process_inactive(cursor, hierarchy)
    cnx.commit()
    cnx.close()

    create_hierarchy_files(hierarchy, coldfront2resource)


if __name__ == "__main__":
    main()
