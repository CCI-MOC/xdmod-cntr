#!/usr/bin/python3
import os
import sys
import subprocess
import time
import argparse
import json
import pprint
import mysql.connector


def exec_sql(cursor, sql_stmt, params, error_msg):

    cursor.execute(sql_stmt, params)


def exec_fetchall(cursor, sql_stmt, params):
    """executes the sql statmement and fetches all in a list"""
    cursor.execute(sql_stmt, params)
    result = cursor.fetchall()
    return result


def exec_fetchone(cursor, sql_stmt, params):
    """executes the sql stmt and fetches the first one in the result list"""
    cursor.execute(sql_stmt, params)
    result = cursor.fetchone()
    if result:
        return result[0]
    else:
        return None


def connect_to_db(database):
    pprint.pprint(database)
    host = database["host"]
    admin_acct = "root"
    admin_pass = database["admin_password"]
    # it is ok if the file doesn't as the clouds.yaml is possibly empty or manually updated
    cnx = mysql.connector.connect(host=host, user=admin_acct, password=admin_pass)
    return cnx


def write_file_from_db(cursor, script):
    """As a work-a-round for RWM, share config files though the database"""
    print(f"write {script} file_share_db")
    data = exec_fetchall(cursor, "select file_name, file_data from file_share_db.file where script=%s", (script,))

    if data and isinstance(data, list):
        rec = data[0]
        file = rec[0]
        directory = os.path.dirname(file)
        if not os.path.isdir(directory):
            print(f"Creating Direcotry {directory}")
            os.makedirs(directory)
        with open(file, "wb+") as fp:
            fp.write(rec[1])


def do_parse_args(config):
    """Parse args and return a config dict"""
    parser = argparse.ArgumentParser(description="pulls a config file from the database")
    parser.add_argument("-u", "--user", help="use_name", required=False)
    parser.add_argument("-p", "--passwd", help="password", required=False)
    parser.add_argument("-h", "--host", help="db host", required=False)

    args = parser.parse_args()

    if args.user:
        config["user"] = args.user
    if args.passwd:
        config["pass"] = args.passwd
    if args.host:
        config["host"] = args.host

    return config


def main():
    """the main function"""
    config = {}

    try:
        with open("/etc/xdmod/xdmod_init.json", "r", encoding="utf-8") as file:
            config = json.load(file)["database"]
    except IOError:
        work_dir = os.getcwd()
        print(f"Ensure the xdmod-init.json file is in the working directory /etc/xdmod/xdmod_init.json")

    cnx = connect_to_db(config)
    file_keys = [
        "openstack-cloud-config",
        "xdmod-config",
        "xdmod-linker",
        "xdmod-colors1",
        "xdmod-organization",
        "xdmod-hierarchy",
        "xdmod-resources",
        "xdmod-resource-types",
        "xdmod-etl",
        "xdmod-etl-acls",
        "xdmod-etl-cloud-state",
        "xdmod-etl-ingest-resources",
        "xdmod-etl-cloud-openstack",
        "xdmod-etl-shredder",
        "xdmod-etl-verify",
        "xdmod-etl-acls-management",
        "xdmod-etl-gateways",
        "xdmod-etl-jobs",
        "xdmod-etl-jobs-common",
        "xdmod-etl-staging",
        "xdmod-etl-xdb",
        "xdmod-etl-action-state",
        "xdmod-etl-hpcdb-xdw",
        "xdmod-etl-jobs-cloud-common",
        "xdmod-etl-organizations",
        "xdmod-etl-storage",
        "xdmod-etl-migration",
        "xdmod-etl-cloud-ingest-resource-specs",
        "xdmod-etl-hpcdb",
        "xdmod-etl-cloud-generic",
        "xdmod-etl-resource-types",
        "xdmod-etl-test-suite",
    ]
    cursor = cnx.cursor()

    # for fkey in file_keys:
    #    write_file_from_db(cursor, fkey)
    write_file_from_db(cursor, "etc-xdmod")
    base64 = subprocess.Popen(["/usr/bin/base64", "-d", "/etc/xdmod/etc_xdmod.b64"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    b64_out, b64_err = base64.communicate()
    print(f"errors: {b64_err}")
    with open("/etc/xdmod/etc_xdmod.tgz", "wb") as fptr:
        fptr.write(b64_out)
    os.system("/usr/bin/tar -xzvf /etc/xdmod/etc_xdmod.tgz")
    # subprocess.check_call(["/usr/bin/tar", "-xzvf", "/etc/xdmod/etc_xdmod.tgz"])

    cnx.commit()
    cnx.close()


if __name__ == "__main__":
    main()
