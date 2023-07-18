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


def delete_hdb(cursor):
    """delete the database but only in initial development"""
    if moc_db_helper_functions.db_exist(cursor, "hierarchy_db"):
        cursor.execute("drop database hierarchy_db", None)


def delete_db():
    # read in the xdmod_init.json file to get the database and resource configs
    try:
        with open("/etc/xdmod/xdmod_init.json", "r", encoding="utf-8") as file:
            config = json.load(file)
    except IOError:
        print("Ensure the xdmod-init.json file is in /etc/xdmod/xdmod_init.json")

    cnx = moc_db_helper_functions.connect_to_db(config["database"])
    cursor = cnx.cursor(dictionary=True)
    if moc_db_helper_functions.db_exist(cursor, "hierarchy_db"):
        delete_hdb(cursor)
