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
import pprint
import copy
import hashlib
import moc_db_helper_functions
import get_users_from_keycloak

development_only = True


def get_data_from_coldfront():
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
            create_ts timestamp, \
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
    pprint.pprint(current_dict)


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


def create_hierarchy_files(hierarchy):
    """
    This builds the hierarchy files from the data coming from coldfront, keycloak
    and historic data from the database
    """
    # construct hierarchy.csv
    with open("hierarchy.csv", "w", encoding="utf-8") as hierarchy_file:
        for rec_id, rec in hierarchy["institution"].items():
            hierarchy_file.write(f"{rec_id},{rec['name']},\n")
        for l2_id, l2 in hierarchy["field-of-science"].items():
            hierarchy_file.write(f"{l2_id},{l2['name']},{l2['parent_id']}\n")
        for l3_id, l3_rec in hierarchy["pi"].items():
            hierarchy_file.write(f"{l3_id},{l3_rec['name']},{l3_rec['parent_id']}\n")

    # constrcut groups.csv (level 4 of the hierarchy, though this is a mapping table between pi/group and the hiearachy)
    with open("group.csv", "w", encoding="utf-8") as group_file:
        for l4_id, l4_rec in hierarchy["project"].items():
            l3_rec = hierarchy["pi"][l4_rec["parent_id"]]
            group_file.write(f'"{l4_rec["name"]}", "{l4_rec["parent_id"]}"\n')

    # constrcut pi2project
    with open("pi2project.csv", "w", encoding="utf-8") as pi2project_file:
        for l5 in hierarchy["cloud-project"].values():
            l4_rec = hierarchy["cloud-project"][l5["parent_id"]]
            l4_id = l4_rec["id"]
            pi2project_file.write(f"{hierarchy['cloud-project'][l4_id]['name']}, {l5['name']}\n")

    # construct the names (rename projects)


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
        "select * from hierarchy_db.hierarchy_rec hr where hr.type='openstack-project' order by hr.create_ts",
        None,
    )
    return hierarchy


def process_coldfront_data(cursor, hierarchy):
    """this processes the coldfront data (pi and project/cloud-project
        into the hierarchy
    )"""
    coldfront_data = get_data_from_coldfront()
    for record in coldfront_data:
        # have to assume that the PI is active if it is coming from cold-front
        pi_rec = {
            "type": "pi",
            "name": record["project"]["pi"],
            "display_name": record["project"]["pi"],
            "status": "Active",
        }
        pi_id = find_hierarchy_id(pi_rec["name"], hierarchy["pi"])

        # (institution, field_of_science) get_institution_and_fos_from_keycloak()
        # inst_id = find_hierarchy_id(institution, hierarchy["institution"])
        # fos_id = find_hierarchy_id(institution, hierarchy["field-of-science"])
        if pi_id:
            # there is a pi_id
            pi_rec["id"] = pi_id
            parent_id = (hierarchy["pi"][pi_id]).get("parent_id")
            if parent_id:
                pi_rec["parent_id"] = parent_id
            else:
                pi_rec["parent_id"] = find_hierarchy_id("unknown", hierarchy["field-of-science"])
        else:
            # look  up field-of-science and institutuion in keycloak
            # for now assign "unknown"
            pi_rec["parent_id"] = find_hierarchy_id("unknown", hierarchy["field-of-science"])

        process_record(cursor, pi_rec, hierarchy["pi"])

        if not pi_id:
            pi_id = find_hierarchy_id(pi_rec["name"], hierarchy["pi"])
            pi_rec = hierarchy["pi"][pi_id]

        project_rec = {
            "name": record["attributes"]["Allocated Project ID"],
            "display_name": f"{record['project']['title']} - {record['attributes']['Allocated Project Name']}",
            "parent_id": pi_id,
            "status": record["status"],
        }
        if project_rec["name"] == "5e1cbcfe729a4c7e8fb2fd5328456eea":
            print(f"{project_rec['name']}")
        if not project_rec["name"]:
            project_rec["name"] = project_rec["display_name"]

        if record["resource"]["name"] == "NERC-OCP" and record["resource"]["resource_type"] == "OpenShift":
            project_rec["type"] = "openshift-project"
            process_record(cursor, project_rec, hierarchy["project"])
        elif record["resource"]["name"] == "NERC" and record["resource"]["resource_type"] == "OpenStack":
            project_rec["type"] = "openstack-project"
            process_record(cursor, project_rec, hierarchy["project"])
            project_rec["id"] = find_hierarchy_id(project_rec["name"], hierarchy["project"])
            project_rec["parent_id"] = project_rec["id"]
            process_record(cursor, project_rec, hierarchy["cloud-project"])
        else:
            print("Unknown project record type")
            pprint.pprint(record)


def main():
    """the main function"""
    config = {"host": "localhost", "xdmod_password": "pass", "admin_password": "pass"}

    # try:
    #    with open("/etc/xdmod/xdmod_init.json", "r", encoding="utf-8") as file:
    #        config = json.load(file)["database"]
    # except IOError:
    #    print("Ensure the xdmod-init.json file is in /etc/xdmod/xdmod_init.json")

    cnx = moc_db_helper_functions.connect_to_db(config)
    cursor = cnx.cursor(dictionary=True)

    if not moc_db_helper_functions.db_exist(cursor, "hierarchy_db"):
        create_hierarchy_db(cursor)
        cnx.commit()

    hierarchy = get_hierarchy_from_db(cursor)
    process_coldfront_data(cursor, hierarchy)

    # projects is consider tier 4 of this hierarchy, and cloud_projects is lower, so the parent_id of the cloud_projects
    # will point to the id in the projects - which happens to be the same as it's id
    for rec_id, rec in hierarchy["cloud-project"].items():
        rec["parent_id"] = rec_id

    # update the database changing the status of the records that haven't been accessed
    cnx.commit()
    cnx.close()

    create_hierarchy_files(hierarchy)

    # Now to swap the bottom layer with the project layer (switch pi and project)
    new_bottom_layer = {}
    new_pis = {}
    new_pi_id_count = 0
    for cloud_project in hierarchy["cloud-project"].values():
        project_id = cloud_project["parent_id"]
        pi_id = hierarchy["project"][project_id]["parent_id"]
        new_bottom_layer[project_id] = copy.copy(hierarchy["project"][project_id])
        new_bottom_layer[project_id]["parent_id"] = hierarchy["pi"][pi_id]["parent_id"]
        new_pi_id_count = new_pi_id_count + 1
        new_pi_id = hierarchy["pi"][pi_id]["name"] + str(new_pi_id_count)
        new_pis[new_pi_id] = copy.copy(hierarchy["pi"][pi_id])
        new_pis[new_pi_id]["parent_id"] = project_id
        cloud_project["parent_id"] = new_pi_id

    for project_id, project_rec in hierarchy["project"].items():
        if project_rec["type"] == "openshift-project":
            new_bottom_layer[project_id] = copy.copy(project_rec)
            new_bottom_layer[project_id]["parent_id"] = hierarchy["pi"][project_rec["parent_id"]]["parent_id"]
            new_pi_id_count = new_pi_id_count + 1
            new_pi_id = hierarchy["pi"][project_rec["parent_id"]]["name"] + str(new_pi_id_count)
            new_pis[new_pi_id] = copy.copy(hierarchy["pi"][project_rec["parent_id"]])
            new_pis[new_pi_id]["parent_id"] = project_id

    # modify only if needed!!!
    # create_hierarchy_files(top_layer, mid_layer, new_bottom_layer, new_pis, cloud_project_layer)


if __name__ == "__main__":
    main()
