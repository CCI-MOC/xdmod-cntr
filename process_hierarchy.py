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


def get_data():
    """this just fetches idealized data and will eventually go away!"""
    with open("../hierarchy_data.json", "r", encoding="utf-8") as hierarchy_file:
        data = json.load(hierarchy_file)
        for rec in data:
            rec["status"] = "Active"
        return data
    return None


def create_hierarchy_db(cursor):
    """creates the tables of the hierarchy database"""
    cursor.execute("create database hierarchy_db", None)
    cursor.execute(
        "create table hierarchy_db.hierarchy_rec ( \
            id varchar(256), \
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
    cursor.execute(
        "create sequence hierarchy_db.hierarchy_db_id_seq start with 3 increment by 1;"
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
            ('1', now(), 'institution', 'unknown', 'Active', 'Unknown', null )\
        )",
        None,
    )


def delete_hierarchy_db(cursor):
    """delete the database but only in initial development"""
    if moc_db_helper_functions.db_exist(cursor, "hierarchy_db"):
        cursor.execute("drop database hierarchy_db", None)


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
        add_update = False

        if current_dict[hierarchy_id]["name"] != rec["name"]:
            add_update = True
        if current_dict[hierarchy_id]["display_name"] != rec["display_name"]:
            add_update = True
        if current_dict[hierarchy_id]["parent_id"] != rec["parent_id00"]:
            add_update = True
        if add_update:
            # create a new record with a new id
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
        # id = cursor.lastrowid
        result = (
            moc_db_helper_functions.exec_fetchall(
                cursor,
                "select id from hierarchy_rec hr where hr.type=%(type)s and hr.name=%(name)s",
                {"type": rec["type"], "name": rec["name"]},
            )
        )[0]
        hierarchy_id = None
        if result and "id" in result:
            hierarchy_id = result["id"]
        if hierarchy_id:
            current_dict[hierarchy_id] = copy.copy(rec)
            current_dict[hierarchy_id]["id"] = id
            current_dict[hierarchy_id]["still_active"] = True
    pprint.pprint(current_dict)


def create_hierarchy_dictionary(cursor, sql_stmt, params):
    """
    This creates a dictionary of the records returned

    currently the primary key is (id, create_ts) in order to
    track history -
    """
    records = moc_db_helper_functions.exec_fetchall(cursor, sql_stmt, params)
    ret_dict = {}
    for rec in records:
        ret_dict[rec["id"]] = copy.deepcopy(rec)
    return ret_dict


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
            unique_key = create_xdmod_key(rec_id)
            hierarchy_file.write(f"{unique_key},{rec['name']},\n")
        for l2_id, l2 in hierarchy["field-of-science"].items():
            unique_key = create_xdmod_key(
                hierarchy["inistitution"][l2["parent_id"]], l2_id
            )
            parent_key = create_xdmod_key(l2["parent_id"])
            hierarchy_file.write(f"{unique_key},{l2['name']},{parent_key}\n")
        for l3_id, l3_rec in hierarchy["pi"].items():
            unique_key = create_xdmod_key(
                (hierarchy["field-of-science"][l3_rec["parent_id"]])["parent_id"],
                l3_rec["parent_id"],
                l3_id,
            )
            parent_key = create_xdmod_key(
                (hierarchy["field-of-science"][l3_rec["parent_id"]])["parent_id"],
                l3_rec["parent_id"],
            )
            hierarchy_file.write(f"{unique_key},{l3_rec['name']},{parent_key}\n")

    # constrcut groups.csv (level 4 of the hierarchy, though this is a mapping table between pi/group and the hiearachy)
    with open("group.csv", "w", encoding="utf-8") as group_file:
        for l4_id, l4_rec in hierarchy["project"].items():
            l3_rec = hierarchy["pi"][l4_rec["parent_id"]]
            unique_key = create_xdmod_key(
                (hierarchy["field-of-science"][l3_rec["parent_id"]])["parent_id"],
                l3_rec["parent_id"],
                l3_rec["id"],
            )
            group_file.write(f'"{l4_rec["name"]}", "{unique_key}" \n')

    # constrcut pi2project
    with open("pi2project.csv", "w", encoding="utf-8") as pi2project_file:
        for l5 in hierarchy["cloud-project"].values():
            l4_rec = hierarchy["cloud-project"][l5["parent_id"]]
            l4_id = l4_rec["id"]
            pi2project_file.write(
                f"{hierarchy['cloud-project'][l4_id]['name']}, {l5['name']}\n"
            )

    # construct the names (rename projects)


def find_hierarchy_id(name, dictionary):
    """returns the hierarchy_id if found in the dictionary"""
    for rec in dictionary.values():
        if name == rec["name"]:
            return rec["id"]
    return None


def get_hierarchy_from_db(cursor):
    """This fetches the data from the database and only keeps the most recent record based on its id"""
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


def process_expected_data(cursor, hierarchy):
    """This fits idealized data into the hierarchy from the database

    This is currently needed as we are not getting the data from
    keycloak yet.
    """
    data = get_data()
    for record in data:
        match record["type"]:
            case "institution":
                process_record(cursor, record, hierarchy["institution"])
            case "field-of-science":
                process_record(cursor, record, hierarchy["field-of-science"])
            case "pi":
                process_record(cursor, record, hierarchy["pi"])
            case "openshift-project":
                process_record(cursor, record, hierarchy["project"])
            case "openstack-project":
                process_record(cursor, record, hierarchy["project"])
                record["parent_id"] = record["id"]
                process_record(cursor, record, hierarchy["cloud-project"])
    return 1


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
        if not pi_id:
            # need to assign unknown as field of science and univeristy
            pi_rec["parent_id"] = find_hierarchy_id(
                "unknown", hierarchy["field-of-science"]
            )

        process_record(cursor, pi_rec, hierarchy["pi"])

        project_rec = {
            "name": record["attributes"]["Allocated Project ID"],
            "display_name": record["attributes"]["Allocated Project Name"],
            "parent_id": record["project"]["pi"],
            "status": record["status"],
        }

        if (
            record["resource"]["name"] == "NERC"
            and record["resource"]["resource_type"] == "OpenShift"
        ):
            project_rec["type"] = "openshift-project"
            process_record(cursor, project_rec, hierarchy["project"])
        elif (
            record["resource"]["name"] == "NERC"
            and record["resource"]["resource_type"] == "OpenStack"
        ):
            project_rec["type"] = "openstack-project"
            process_record(cursor, project_rec, hierarchy["project"])
            project_rec["parent_id"] = record["id"]
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

    # This is here for development
    if moc_db_helper_functions.db_exist(cursor, "hierarchy_db"):
        delete_hierarchy_db(cursor)

    if not moc_db_helper_functions.db_exist(cursor, "hierarchy_db"):
        create_hierarchy_db(cursor)

    hierarchy = get_hierarchy_from_db(cursor)
    process_expected_data(cursor, hierarchy)
    process_coldfront_data(cursor, hierarchy)

    # projects is consider tier 4 of this hierarchy, and cloud_projects is lower, so the parent_id of the cloud_projects
    # will point to the id in the projects - which happens to be the same as it's id
    for rec_id, rec in hierarchy["cloud-project"].items():
        rec["parent_id"] = rec_id
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
            new_bottom_layer[project_id]["parent_id"] = hierarchy["pi"][
                project_rec["parent_id"]
            ]["parent_id"]
            new_pi_id_count = new_pi_id_count + 1
            new_pi_id = hierarchy["pi"][project_rec["parent_id"]]["name"] + str(
                new_pi_id_count
            )
            new_pis[new_pi_id] = copy.copy(hierarchy["pi"][project_rec["parent_id"]])
            new_pis[new_pi_id]["parent_id"] = project_id

    # modify only if needed!!!
    # create_hierarchy_files(top_layer, mid_layer, new_bottom_layer, new_pis, cloud_project_layer)


if __name__ == "__main__":
    main()
