#!/usr/bin/python3
import os
import sys
import time
import argparse
import json
import pprint
import mysql.connector


def exec_sql(cursor, sql_stmt, params, error_msg):
    """executes a simple sql statement"""
    try:
        cursor.execute(sql_stmt, params)
    except Exception as err:
        print(f"{str(err)} \n {error_msg}")
        sys.exit()


def exec_fetchall(cursor, sql_stmt, params, error_msg):
    """executes the sql statmement and fetches all in a list"""
    exec_sql(cursor, sql_stmt, params, error_msg)
    try:
        result = cursor.fetchall()
    except Exception as err:
        print(f"{str(err)} \n {error_msg}")
        sys.exit()
    return result


def exec_fetchone(cursor, sql_stmt, params, error_msg):
    """executes the sql stmt and fetches the first one in the result list"""
    exec_sql(cursor, sql_stmt, params, error_msg)
    try:
        result = cursor.fetchone()
    except Exception as err:
        print(f"{str(err)} \n {error_msg}")
        sys.exit()
    if result:
        return result[0]
    else:
        return None


def write_file_from_db(database, script):
    """As a work-a-round for RWM, share config files though the database"""
    host = database["host"]
    admin_acct = "root"
    admin_pass = database["admin_password"]
    # it is ok if the file doesn't as the clouds.yaml is possibly empty or manually updated
    try:
        cnx = mysql.connector.connect(host=host, user=admin_acct, password=admin_pass)
    except mysql.connector.Error as err:
        print(str(err))
        sys.exit()
    print(f"write {script} file_share_db")
    cursor = cnx.cursor()

    print(f"select file_name, file_data from file_share_db.file where script='{script}'")
    data = exec_fetchall(
        cursor,
        "select file_name, file_data from file_share_db.file where script=%s",
        (script,),
        "Unable to select file from db",
    )
    pprint.pprint(data)
    if data and isinstance(data, list):
        rec = data[0]
        with open(rec[0], "wb+") as fp:
            fp.write(rec[1])

    cnx.commit()
    cnx.close()


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
    if os.path.isfile("./xdmod_init.json"):
        try:
            with open("./xdmod_init.json", "r", encoding="utf-8") as file:
                config = json.load(file)["database"]
        except IOError:
            work_dir = os.getcwd()
            print(f"Ensure the xdmod-init.json file is in the working directory {work_dir}")
    # only do this if it is necessary
    # config = do_parse_args(config)

    write_file_from_db(config, "openstack-cloud-config")
    time.sleep(20)
    write_file_from_db(config, "xdmod-config")
    time.sleep(20)
    write_file_from_db(config, "xdmod-linker")


main()
