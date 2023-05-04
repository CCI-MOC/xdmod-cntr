"""
script that saves xdmod's configuration to a db in order to share it
with cron jobs that are being run in separate pods (the shredder and
the ingestor kubernetes cron jobs)
"""
import os
import json
import moc_db_helper_functions as moc_db


def main():
    """Creates the tarball to upload to the database and cleansup after itself"""
    with open("/etc/xdmod/xdmod_init.json", encoding="utf-8") as json_file:
        xdmod_init_json = json.load(json_file)
        cnx = moc_db.connect_to_db(xdmod_init_json["database"])

        os.system("tar -czf /etc/xdmod/etc_xdmod.tgz /etc/xdmod/*")
        os.system("base64 /etc/xdmod/etc_xdmod.tgz > /etc/xdmod/etc_xdmod.b64")
        moc_db.save_file_to_db(cnx.cursor(), "/etc/xdmod/etc_xdmod.b64", "etc-xdmod")
        os.system("rm /etc/xdmod/etc_xdmod.tgz")
        os.system("rm /etc/xdmod/etc_xdmod.b64")

        cnx.commit()
        cnx.close()


main()
