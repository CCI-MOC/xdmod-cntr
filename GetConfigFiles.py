#!/usr/local/bin/python3
""" This pulls the config files from the database and copies them in to /etc/xdmod

    Will be unnecessary if RWX volumes become available
"""
# pylint: disable=line-too-long invalid-name
import os
import subprocess
import json
import mysql.connector


def exec_fetchall(cursor, sql_stmt, params):
    """executes the sql statmement and fetches all in a list"""
    cursor.execute(sql_stmt, params)
    result = cursor.fetchall()
    return result


def connect_to_db(database):
    """This just connects to the database and returns the connection"""
    host = database["host"]
    admin_acct = "root"
    admin_pass = database["admin_password"]
    # it is ok if the file doesn't as the clouds.yaml is possibly empty or manually updated
    cnx = mysql.connector.connect(host=host, user=admin_acct, password=admin_pass)
    return cnx


def write_file_from_db(cursor, script):
    """As a work-a-round for RWM, share config files though the database"""
    print(f"write {script} file_share_db")
    data = exec_fetchall(
        cursor,
        "select file_name, file_data from file_share_db.file where script=%s",
        (script,),
    )

    if data and isinstance(data, list):
        rec = data[0]
        file = rec[0]
        directory = os.path.dirname(file)
        if not os.path.isdir(directory):
            print(f"Creating Direcotry {directory}")
            os.makedirs(directory)
        with open(file, "wb+") as fp:
            fp.write(rec[1])


def main():
    """the main function"""
    config = {}

    try:
        with open("/etc/xdmod/xdmod_init.json", "r", encoding="utf-8") as file:
            config = json.load(file)["database"]
    except IOError:
        print("Ensure the xdmod-init.json file is in /etc/xdmod/xdmod_init.json")

    cnx = connect_to_db(config)
    cursor = cnx.cursor()

    write_file_from_db(cursor, "etc-xdmod")
    with subprocess.Popen(
        ["/usr/bin/base64", "-d", "/etc/xdmod/etc_xdmod.b64"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ) as base64:
        b64_out, b64_err = base64.communicate()
        print(f"errors: {b64_err}")
        with open("/etc/xdmod/etc_xdmod.tgz", "wb") as fptr:
            fptr.write(b64_out)
        os.system("/bin/tar -xzf /etc/xdmod/etc_xdmod.tgz --directory /")

    cnx.commit()
    cnx.close()


if __name__ == "__main__":
    main()
