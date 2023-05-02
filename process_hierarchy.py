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
import sys
import logging
import hashlib
import moc_db_helper_functions

# import get_users_from_keycloak

# only here for development
keycloak_data = {}


def get_keycloak_data(username):
    """
    This links institution, field-of-science and PI together

    expected format:
    [{
        'access': {
            'impersonate': True,
            'manage': True,
            'manageGroupMembership': True,
            'mapRoles': True,
            'view': True
        },
        'attributes': {
            'cilogon_idp_name': ['<institution>'],
            'mss_research_domain': ['<field-of-science>']
        },
        'createdTimestamp': <unix timestamp>,
        'disableableCredentialTypes': [],
        'email': '<PI's email>',
        'emailVerified': True,
        'enabled': True,
        'firstName': '<PI's first name>',
        'id': '<id>',
        'lastName': '<PI's last name>',
        'notBefore': 0,
        'requiredActions': [],
        'totp': False,
        'username': '<PI's username>'
        },
        ...
    ]
    """
    keycloak_rec = keycloak_data.get(username)
    if not keycloak_rec:
        with open("../keycloak_data.json", "r", encoding="utf-8") as keycloak_file:
            keycloak_records = json.load(keycloak_file)
        if len(keycloak_records) == 0:
            logging.error("zero keycloak records found")
            sys.exit()
        for rec in keycloak_records:
            keycloak_data[rec["username"]] = rec
        return keycloak_data.get(username)
    return keycloak_rec


def get_coldfront_data():
    """
    This links PI with project/cloud_project.

    This fetches the allocation data from coldfront with the format of:
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
    with open("../coldfront_data.json", "r", encoding="utf-8") as coldfront_file:
        data = json.load(coldfront_file)
        return data
    return None


def create_hierarchy_db(cursor):
    """creates the tables of the hierarchy database"""
    cursor.execute("create database hierarchy_db", None)
    cursor.execute(
        "create table hierarchy_db.hierarchy_rec ( \
            id bigint, \
            create_ts datetime, \
            type varchar(100) not null, \
            name varchar(500) not null, \
            status varchar(100), \
            display_name varchar(500), \
            parent_id bigint, \
            primary key (id, create_ts) \
        )",
        None,
    )
    cursor.execute("create sequence hierarchy_db.hierarchy_db_id_seq start with 3 increment by 1;")
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
            (1, now(), 'institution', 'unknown', 'Active', 'Unknown', null ), \
            (2, now(), 'field-of-science', 'unknown', 'Active', 'Unknown', 1)",
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
    hierarchy_id = find_hierarchy_id(rec["name"], current_dict)
    if hierarchy_id:
        if (
            current_dict[hierarchy_id]["name"] != rec["name"]
            or current_dict[hierarchy_id]["display_name"] != rec["display_name"]
            or current_dict[hierarchy_id]["parent_id"] != rec.get("parent_id")
        ):
            # create a new record with a new id
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
                now(), \
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
            # update the dictionary
            current_dict[hierarchy_id]["type"] = rec["type"]
            current_dict[hierarchy_id]["name"] = rec["name"]
            current_dict[hierarchy_id]["display_name"] = rec["display_name"]
            current_dict[hierarchy_id]["status"] = rec["status"]
            current_dict[hierarchy_id]["parent_id"] = rec["parent_id"]
            current_dict[hierarchy_id]["still_active"] = True
    else:
        # create a new record with a new id
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
            nextval(hierarchy_db_id_seq), \
            now(), \
            %(type)s, \
            %(name)s, \
            %(status)s, \
            %(display_name)s, \
            %(parent_id)s \
            )",
            {
                "type": rec["type"],
                "name": rec["name"],
                "display_name": rec["display_name"],
                "status": rec["status"],
                "parent_id": rec["parent_id"],
            },
        )
        # lastrowid doesn't seem to work with nextval()
        # hierarchy_id = cursor.lastrowid
        result = (
            moc_db_helper_functions.exec_fetchall(
                cursor,
                "select id from hierarchy_rec hr where hr.type=%(type)s and hr.name=%(name)s",
                {"type": rec["type"], "name": rec["name"]},
            )
        )[0]
        hierarchy_id = result.get("id")
        if hierarchy_id:
            current_dict[hierarchy_id] = copy.copy(rec)
            current_dict[hierarchy_id]["id"] = hierarchy_id
            current_dict[hierarchy_id]["still_active"] = True


def create_hierarchy_dictionary(cursor, sql_stmt, params):
    """
    This creates a dictionary of the records returned.

    Assuming that the sql places things in chronological order
    this will return a dictionary of the latest record for each id
    """
    records = moc_db_helper_functions.exec_fetchall(cursor, sql_stmt, params)
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
            hierarchy_file.write(f'"{rec_id}","{rec["name"]}",\n')
        for l2_id, l2 in hierarchy["field-of-science"].items():
            hierarchy_file.write(f'"{l2_id}","{l2["name"]}","{l2["parent_id"]}"\n')
        for l3_id, l3_rec in hierarchy["pi"].items():
            hierarchy_file.write(f'"{l3_id}","{l3_rec["name"]}","{l3_rec["parent_id"]}"\n')

    # construct groups.csv (level 4 of the hierarchy, though this is a mapping table between pi/group and the hiearachy)
    with open("group.csv", "w", encoding="utf-8") as group_file:
        for l4_id, l4_rec in hierarchy["project"].items():
            l3_rec = hierarchy["pi"][l4_rec["parent_id"]]
            group_file.write(f'"{l4_rec["name"]}", "{l4_rec["parent_id"]}"\n')

    # construct pi2project
    with open("pi2project.csv", "w", encoding="utf-8") as pi2project_file:
        for l5 in hierarchy["cloud-project"].values():
            l4_rec = hierarchy["project"][l5["parent_id"]]
            l4_id = l4_rec["id"]
            # need to add in a project type ( NERC, openstack ) to resource name ('nerc-ocp-prod')
            pi2project_file.write(f'"{hierarchy["project"][l4_id]["name"]}", "{l5["name"]}", "{coldfront2resource[l4_rec["type"]]["resource_name"]}"\n')

    # construct the names.csv (rename records in the hierarchy)
    with open("names.csv", "w", encoding="utf-8") as name_file:
        for l4_id, l4_rec in hierarchy["project"].items():
            name_file.write(f'"{l4_rec["name"]}", , "{l4_rec["display_name"]}"\n')


def find_hierarchy_id(name, dictionary):
    """returns the hierarchy_id if found in the dictionary"""
    for rec in dictionary.values():
        if name == rec["name"]:
            return rec["id"]
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


def process_data(cursor, hierarchy):
    """
    This combines the cold front data with the
    """
    coldfront_data = get_coldfront_data()
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

        keycloak_rec = get_keycloak_data(pi_rec["name"])

        # find the pi's field of science - the pi's parent_id
        if keycloak_rec is None:
            pi_rec["parent_id"] = find_hierarchy_id("unknown", hierarchy["field-of-science"])
        else:
            # pick the first element of the list and assume it is the primary one
            #  - can the cilogon_idp_name have either 0 or more th1n 1 elements?
            institution = keycloak_rec["attributes"]["cilogon_idp_name"][0]
            institution_id = process_institution(cursor, institution, hierarchy["institution"])
            institution = hierarchy["institution"][institution_id]["name"]

            # here again, pick the first element of the list and assume it is the primary one
            #  - can the mss_research_domain have either 0 or more th1n 1 elements?
            field_of_science = f"{institution} - {keycloak_rec['attributes']['mss_research_domain'][0]}"
            fos_id = find_hierarchy_id(field_of_science, hierarchy["field-of-science"])
            if not fos_id:
                fos_rec = {
                    "type": "field-of-science",
                    "name": field_of_science,
                    "display_name": keycloak_rec["attributes"]["mss_research_domain"][0],
                    "status": "Active",
                    "parent_id": institution_id,
                }
                process_record(cursor, fos_rec, hierarchy["field-of-science"])
                fos_id = find_hierarchy_id(field_of_science, hierarchy["field-of-science"])

            # now that we know the pi's field of science id (fos_id)
            if fos_id:
                pi_rec["parent_id"] = fos_id
            else:
                pi_rec["parent_id"] = find_hierarchy_id("Unknown", hierarchy["field-of-science"])

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

        if record["resource"]["name"] == "NERC-OCP" and record["resource"]["resource_type"] == "OpenShift":
            project_rec["type"] = "NERC-OCP-OpenShift"
            process_record(cursor, project_rec, hierarchy["project"])
        elif record["resource"]["name"] == "NERC" and record["resource"]["resource_type"] == "OpenStack":
            project_rec["type"] = "NERC-OpenStack"
            process_record(cursor, project_rec, hierarchy["project"])
            project_rec["parent_id"] = find_hierarchy_id(project_rec["name"], hierarchy["project"])
            project_rec["type"] = "cloud-project"
            project_rec["id"] = find_hierarchy_id(project_rec["name"], hierarchy["cloud-project"])
            process_record(cursor, project_rec, hierarchy["cloud-project"])
        else:
            logging.info("Unknown project_record type %s", json.dumps(record))


def main():
    """the main function"""
    # read in the xdmod_init.json file to get the database and resource configs
    try:
        with open("/etc/xdmod/xdmod_init.json", "r", encoding="utf-8") as file:
            config = json.load(file)
    except IOError:
        print("Ensure the xdmod-init.json file is in /etc/xdmod/xdmod_init.json")

    coldfront2resource = {}
    for resource in config["resource"]:
        if "ColdFront" in resource:
            coldfront2resource[resource["ColdFront"]] = {"resource_name": resource["name"], "resource_type": resource["type"]}

    cnx = moc_db_helper_functions.connect_to_db(config["database"])
    cursor = cnx.cursor(dictionary=True)

    if not moc_db_helper_functions.db_exist(cursor, "hierarchy_db"):
        create_hierarchy_db(cursor)
        cnx.commit()

    hierarchy = get_hierarchy_from_db(cursor)
    process_data(cursor, hierarchy)

    # update the database changing the status of the records that haven't been accessed
    cnx.commit()
    cnx.close()

    create_hierarchy_files(hierarchy, coldfront2resource)


if __name__ == "__main__":
    main()