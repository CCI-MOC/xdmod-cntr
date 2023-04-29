"""
script that saves xdmod's configuration to a db in order to share it
with cron jobs that are being run in separate pods (the shredder and
the ingestor kubernetes cron jobs)
"""
import os
import json
import mysql.connector


def exec_fetchone(cursor, sql_stmt, params=None):
    """executes the sql stmt and fetches the first one in the result list"""
    cursor.execute(sql_stmt, params)
    result = cursor.fetchone()
    return result[0]


def connect_to_db(database):
    """This just connects to the database"""
    host = database["host"]
    admin_acct = "root"
    admin_pass = database["admin_password"]
    cnx = mysql.connector.connect(host=host, user=admin_acct, password=admin_pass)
    return cnx


def write_file_to_db(cursor, filename, script):
    """As a work-a-round for RWM, share config files though the database"""
    # it is ok if the file doesn't as the clouds.yaml is possibly empty or manually updated
    if os.path.isfile(filename):
        print(f" Writing {filename} to db")
        with open(filename, "rb") as file:
            file_contents = file.read()
            count = exec_fetchone(
                cursor,
                "select count(*) from file_share_db.file where script=%s",
                (script,),
            )
            if count == 0:
                cursor.execute(
                    "insert into file_share_db.file \
                        (script, file_name, file_data) \
                     values \
                        (%s,%s,%s)",
                    (script, filename, file_contents),
                )
            else:
                cursor.execute(
                    "update file_share_db.file \
                     set file_name=%s, file_data=%s where script=%s",
                    (filename, file_contents, script),
                )


def main():
    """Creates the tarball to upload to the database and cleansup after itself"""
    with open("/etc/xdmod/xdmod_init.json", encoding="utf-8") as json_file:
        xdmod_init_json = json.load(json_file)
        cnx = connect_to_db(xdmod_init_json["database"])

        os.system("tar -czf /etc/xdmod/etc_xdmod.tgz /etc/xdmod/*")
        os.system("base64 /etc/xdmod/etc_xdmod.tgz > /etc/xdmod/etc_xdmod.b64")
        write_file_to_db(cnx.cursor(), "/etc/xdmod/etc_xdmod.b64", "etc-xdmod")
        os.system("rm /etc/xdmod/etc_xdmod.tgz")
        os.system("rm /etc/xdmod/etc_xdmod.b64")

        cnx.commit()
        cnx.close()


main()
