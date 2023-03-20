#!/usr/bin/python3
# pylint: disable=line-too-long broad-except too-many-locals too-many-branches too-many-statements
""" Python script to intialize xdmod """
import os
import time
import json
import pexpect
import yaml
import mysql.connector


def xdmod_setup_admin_account(admin_account):
    """uses xdmod-setup to create an admin account"""
    xdmod_admin_account_json = {
        "cmd": "xdmod-setup",
        "do_list": [
            {
                "prompt": r"Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ",
                "resp": "5",
            },
            {"prompt": "Username: ", "resp": admin_account["admin_username"]},
            {"prompt": "Password: ", "resp": admin_account["admin_password"]},
            {
                "prompt": r"\(confirm\) Password: ",
                "resp": admin_account["admin_password"],
            },
            {"prompt": "First name: ", "resp": admin_account["first_name"]},
            {"prompt": "Last name: ", "resp": admin_account["last_name"]},
            {"prompt": "Email address: ", "resp": admin_account["email_address"]},
            {"prompt": "Press ENTER to continue.", "resp": ""},
            {
                "prompt": r"Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ",
                "resp": "q",
                "timeout": 600,
            },
        ],
    }
    run_pexpect_json(xdmod_admin_account_json)


def xdmod_setup_general_settings(general_settings):
    """uses xdmod-setup to configure general settings"""
    xdmod_general_settings_json = {
        "cmd": "xdmod-setup",
        "do_list": [
            {
                "prompt": r"Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ",
                "resp": "1",
            },
            {
                "prompt": r"Site Address: \[.*\]",
                "resp": general_settings["site_address"],
            },
            {
                "prompt": "Email Address:",
                "resp": general_settings["contact_email_address"],
            },
            {"prompt": r"Chromium Path: \[.*\]", "resp": ""},
            {
                "prompt": "Center Logo Path:",
                "resp": general_settings["center_logo_path"],
            },
            {
                "prompt": r"Enable Dashboard Tab \(on, off\)\? \[off\]",
                "resp": general_settings["enable_dashboard"],
            },
            {
                "prompt": r"Overwrite config file '/etc/xdmod/portal_settings.ini' \(yes, no\)\? \[yes\]",
                "resp": "",
            },
            {"prompt": "Press ENTER to continue.", "resp": ""},
            {
                "prompt": r"Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ",
                "resp": "q",
            },
        ],
    }
    run_pexpect_json(xdmod_general_settings_json)


def xdmod_setup_organization(organization):
    """uses xdmod-setup to create the /etc/xdmod/orgainization.json file"""
    xdmod_setup_organization_json = {
        "cmd": "xdmod-setup",
        "do_list": [
            {
                "prompt": r"Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ",
                "resp": "3",
            },
            {"prompt": "Organization Name: ", "resp": organization["name"]},
            {
                "prompt": "Organization Abbreviation: ",
                "resp": organization["abbreviation"],
            },
            {
                "prompt": r"Overwrite config file '/etc/xdmod/organization.json' \(yes, no\)\? \[.*\]",
                "resp": "yes",
            },
            {"prompt": "Press ENTER to continue.*", "resp": ""},
            {
                "prompt": r"Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ",
                "resp": "q",
                "timeout": 600,
            },
        ],
    }
    run_pexpect_json(xdmod_setup_organization_json)


def xdmod_setup_database(database):
    """uses xdmod-setup to create and initialize the databases"""
    xdmod_setup_databases_json = {
        "cmd": "xdmod-setup",
        "do_list": [
            {
                "prompt": r"Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ",
                "resp": "2",
            },
            {"prompt": r"DB Hostname or IP: \[.*\] ", "resp": database["host"]},
            {"prompt": r"DB Port: \[.*\] ", "resp": ""},
            {"prompt": r"DB Username: \[.*\] ", "resp": "xdmod"},
            {"prompt": "DB Password: ", "resp": database["xdmod_password"]},
            {
                "prompt": r"\(confirm\) DB Password: ",
                "resp": database["xdmod_password"],
            },
            {"prompt": r"DB Admin Username: \[root\] ", "resp": ""},
            {"prompt": "DB Admin Password: ", "resp": database["admin_password"]},
            {
                "prompt": r"\(confirm\) DB Admin Password: ",
                "resp": database["admin_password"],
            },
            {
                "prompt": r"Database `mod_shredder` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\] ",
                "resp": "yes",
                "timeout": 600,
                "sleep": 30,
            },
            {
                "prompt": r"Database `mod_hpcdb` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]",
                "resp": "yes",
                "timeout": 600,
                "sleep": 30,
            },
            {
                "prompt": r"Database `moddb` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]",
                "resp": "yes",
                "timeout": 600,
                "sleep": 30,
            },
            {
                "prompt": r"Database `modw` already exists..*\r\nDrop and recreate database \(yes, no\)\? \[.*\]",
                "resp": "yes",
                "timeout": 600,
                "sleep": 30,
            },
            {
                "prompt": r"Database `modw_aggregates` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]",
                "resp": "yes",
                "timeout": 600,
                "sleep": 30,
            },
            {
                "prompt": r"Database `modw_filters` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]",
                "resp": "yes",
                "timeout": 600,
                "sleep": 30,
            },
            {
                "prompt": r"Database `mod_logger` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]",
                "resp": "yes",
                "timeout": 600,
                "sleep": 30,
            },
            {
                "prompt": r"Overwrite config file '/etc/xdmod/portal_settings.ini' \(yes, no\)\? \[.*\]",
                "resp": "yes",
            },
            {"prompt": "Press ENTER to continue.", "resp": ""},
            {
                "prompt": r"Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ",
                "resp": "q",
                "timeout": 1200,
            },  # not sure why this takes so long!!!
        ],
    }
    run_pexpect_json(xdmod_setup_databases_json)


def xdmod_setup_resource(resource):
    """uses xdmod-setup to create the /etc/xdmod/resources.json file"""
    xdmod_setup_resource_json = {
        "cmd": "xdmod-setup",
        "do_list": [
            {"prompt": r"Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\):", "resp": "4"},
            {"prompt": r"Select an option \(1, 2, s\): ", "resp": "1"},
            {"prompt": "Resource Name: ", "resp": resource["name"]},
            {"prompt": "Formal Name:", "resp": resource["formal_name"]},
            {"prompt": r"Resource Type \(.*\): \[.*\] ", "resp": resource["type"]},
            {"prompt": r"How many nodes does this resource have\? ", "resp": "0"},
            {
                "prompt": r"How many total processors \(cpu cores\) does this resource have\? ",
                "resp": "0",
            },
            {"prompt": r"Select an option \(1, 2, s\): ", "resp": "s"},
            {
                "prompt": r"Overwrite config file '/etc/xdmod/resources.json' \(yes, no\)\? \[yes\] ",
                "resp": "yes",
            },
            {"prompt": "Press ENTER to continue. ", "resp": ""},
            {
                "prompt": r"Overwrite config file '/etc/xdmod/resource_specs.json' \(yes, no\)\? \[yes\] ",
                "resp": "yes",
            },
            {"prompt": "Press ENTER to continue. ", "resp": ""},
            {
                "prompt": r"Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\):",
                "resp": "q",
                "timeout": 600,
            },
        ],
    }
    run_pexpect_json(xdmod_setup_resource_json)


def run_pexpect_json(pexpect_json):
    """Processes an dictionary with pexpect"""
    setup = pexpect.spawn(pexpect_json["cmd"])
    print(f"running comand {pexpect_json['cmd']}")
    for prompt_resp in pexpect_json["do_list"]:
        print(f"{prompt_resp['prompt']}\n")
        time_out = 30
        if "timeout" in prompt_resp:
            time_out = prompt_resp["timeout"]
        setup.expect(prompt_resp["prompt"], timeout=time_out)
        nap_time = 0.2
        if "sleep" in prompt_resp:
            nap_time = prompt_resp["sleep"]
        time.sleep(nap_time)
        setup.sendline(prompt_resp["resp"])


def exec_fetchall(cursor, sql_stmt, params=None):
    """executes the sql statmement and fetches all in a list"""
    cursor.execute(sql_stmt, params)
    return cursor.fetchall()


def exec_fetchone(cursor, sql_stmt, params=None):
    """executes the sql stmt and fetches the first one in the result list"""
    cursor.execute(sql_stmt, params)
    result = cursor.fetchone()
    return result[0]


def initialize_database(database, db_list):
    """This does things that xdmod-setup should do - namely:
    1) sets the sql_mode variable to "" - as is expected by xdmod
    2) creates a use that can log in from any remote container
    3) granst permissions on all of the databases that will be initilized
    """
    host = database["host"]
    admin_acct = "root"
    admin_pass = database["admin_password"]
    acct = "xdmod"
    password = database["xdmod_password"]
    # This part should be done in xdmod-setup
    cnx = mysql.connector.connect(host=host, user=admin_acct, password=admin_pass)
    print("Connected to database ")
    cursor = cnx.cursor()

    cursor.execute("set global sql_mode=''")
    cursor.execute("set local sql_mode=''")
    cursor.execute("set global autocommit=1")
    cursor.execute("set local autocommit=1")

    user_count = exec_fetchone(
        cursor,
        "select count(*) from mysql.user where mysql.user.host=%s and mysql.user.user=%s",
        (host, acct),
    )

    print(f"    user_count(1) = {user_count}")
    if user_count == 0:
        cursor.execute("create user %s@%s identified by %s", (acct, host, password))

    user_count = exec_fetchone(
        cursor,
        "select count(*) from mysql.user where mysql.user.host=%s and mysql.user.user=%s",
        ("%", acct),
    )
    print(f"    user_count(2) = {user_count}")
    if user_count == 0:
        cursor.execute("create user %s@%s identified by %s", (acct, "%", password))

    print("sql mode set")
    database_names = exec_fetchall(
        cursor, "select schema_name from information_schema.schemata"
    )

    tmp_database_names = []
    for item in database_names:
        tmp_database_names.append(item[0])
    database_names = tmp_database_names

    print("Creating databases")
    for dbname in db_list:
        if dbname not in database_names:
            cursor.execute(f"create database {dbname} default character set 'utf8'")
        cursor.execute(
            f"grant all on {dbname}.* to %s@%s identified by %s", (acct, host, password)
        )
        cursor.execute(
            f"grant all on {dbname}.* to %s@%s identified by %s", (acct, "%", password)
        )

    cursor.execute("flush privileges")

    # check to see if there are any table defined in any of the schemas
    table_count = 0
    for dbname in db_list:
        count = exec_fetchone(
            cursor,
            "select count(*) from information_schema.tables where table_schema=%s",
            (dbname,),
        )
        table_count += count

    cnx.close()
    print(f"table_count = {table_count}")
    return table_count


def create_file_share_db(cnx):
    """As a work-a-round for RWM, share config files though the database"""
    cursor = cnx.cursor()
    count = exec_fetchone(
        cursor,
        "select count(*) from information_schema.tables where table_schema='file_share_db'",
    )
    if count < 1:
        cursor.execute("drop database if exists file_share_db")
        cursor.execute("create database file_share_db default character set 'utf8'")
        cursor.execute(
            "create table file_share_db.file ( script varchar(500), file_name varchar(2000), file_data longblob, primary key (script))"
        )


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
                    "insert into file_share_db.file (script, file_name, file_data) values (%s,%s,%s)",
                    (script, filename, file_contents),
                )
            else:
                cursor.execute(
                    "update file_share_db.file set file_name=%s, file_data=%s where script=%s",
                    (filename, file_contents, script),
                )


def main():
    """This handles both of the init containers"""
    if os.path.isdir("/mnt/xdmod_conf"):
        # This can only be on the first init container
        # On the NERC there is a 'lost+found', '.', '..' directories that can be ignored
        #     the simplest check is to see that the directory contains less than 5 items
        print("Found /mnt/xdmod* ")
        nap_time = 0
        if len(os.listdir("/mnt/xdmod_conf")) < 5:
            print(" empty directory xdmod_conf found - initializing")
            os.popen("cp -r /etc/xdmod/* /mnt/xdmod_conf")
            if os.path.isfile("/root/xdmod_init.json"):
                os.popen("cp /root/xdmod_init.json /mnt/xdmod_conf/xdmod_init.json")
            nap_time = 30

        if os.path.isdir("/mnt/httpd_conf") and os.path.isfile(
            "/root/httpd/httpd.conf"
        ):
            print("  copy over the httpd configuration ")
            os.popen("cp -r /etc/httpd/* /mnt/httpd_conf")
            os.popen("cp /root/httpd/httpd.conf /mnt/httpd_conf/conf/httpd.conf")
            nap_time = 30

        # this only exists in development
        if os.path.isdir("/mnt/xdmod_src") and len(os.listdir("/mnt/xdmod_src")) < 5:
            print(" empty directory xdmod_src - inializing")
            os.popen("cp -r /usr/share/xdmod/* /mnt/xdmod_src")
            nap_time = 30

        if not os.path.isfile("/root/xdmod_init.json"):
            print(" copy over xdmod_init.json")
            os.popen("cp /root/xdmod_init/xdmod_init.json /mnt/xdmod_conf")
            nap_time = 30

        if nap_time > 0:
            print(f" wait {nap_time} seconds for buffers to flush ")
            time.sleep(nap_time)
        return

    if os.path.isfile("/etc/xdmod/xdmod_init.json"):
        print("Create the file share database")

        print("xdmod_init.json found, attempting to initialize xdmod ")
        with open("/etc/xdmod/xdmod_init.json", encoding="utf-8") as json_file:
            xdmod_init_json = json.load(json_file)
            print("Intializing general settings")
            xdmod_setup_general_settings(xdmod_init_json["general_settings"])

            print("Databases:")
            db_list = [
                "mod_shredder",
                "mod_hpcdb",
                "moddb",
                "modw",
                "modw_aggregates",
                "modw_filters",
                "mod_logger",
                "modw_cloud",
            ]
            table_count = initialize_database(xdmod_init_json["database"], db_list)
            print(f"   table_count = {table_count}")

            if table_count == 0:
                print("    seting up databases (and resources)")
                xdmod_setup_database(xdmod_init_json["database"])

                print("Administrative Account:")
                xdmod_setup_admin_account(xdmod_init_json["admin_account"])

            resource_dict = {}
            if os.path.isfile("/etc/xdmod/resources.json"):
                with open(
                    "/etc/xdmod/resources.json", encoding="utf-8"
                ) as resource_file:
                    resources = json.load(resource_file)
                    for res in resources:
                        resource_dict[res["resource"]] = res
            cloud_conf_dict = {}
            if os.path.isfile("/etc/openstack/clouds.yaml"):
                with open(
                    "/etc/openstack/clouds.yaml", encoding="utf-8"
                ) as cloud_conf_file:
                    cloud_conf_dict = yaml.load(cloud_conf_file, Loader=yaml.FullLoader)

            for resource in xdmod_init_json["resource"]:
                if (not resource_dict) or (resource["name"] not in resource_dict):
                    xdmod_setup_resource(
                        resource
                    )  # this has the side effect of updating the resources.json config filef
                if "auth_url" in resource:
                    # find the app creds or username/password
                    if os.path.isfile(
                        f"/root/resources/{resource['name']}/client_id"
                    ) and os.path.isfile(
                        f"/root/resources/{resource['name']}/client_secret"
                    ):
                        with open(
                            f"/root/resources/{resource['name']}/client_id",
                            encoding="utf-8",
                        ) as file:
                            client_id = file.readline()
                        with open(
                            f"/root/resources/{resource['name']}/client_secret",
                            encoding="utf-8",
                        ) as file:
                            client_secret = file.readline()
                        if (not cloud_conf_dict) or (
                            resource["name"] not in cloud_conf_dict["clouds"]
                        ):
                            cloud_conf_dict["clouds"] = {
                                resource["name"]: {
                                    "auth": {
                                        "auth_url": resource["auth_url"],
                                        "application_credential_id": client_id,
                                        "application_credential_secret": client_secret,
                                    },
                                    "interface": "public",
                                    "identity_api_version": 3,
                                    "auth_type": "v3applicationcredential",
                                }
                            }
                        else:
                            cloud_conf_dict["clouds"][resource["name"]] = {
                                "auth": {
                                    "auth_url": resource["auth_url"],
                                    "application_credential_id": client_id,
                                    "application_credential_secret": client_secret,
                                },
                                "interface": "public",
                                "identity_api_version": 3,
                                "auth_type": "v3applicationcredential",
                            }

                if not os.path.isdir(f"/root/xdmod_data/{resource['name']}"):
                    os.popen(f"mkdir /root/xdmod_data/{resource['name']}")
            if len(cloud_conf_dict) > 0:
                with open("/etc/openstack/clouds.yaml", "w", encoding="utf-8") as file:
                    yaml.dump(cloud_conf_dict, file)
            # always setup the organization - xdmod requires the organization file to be present in order to run
            print(" Organization ")
            xdmod_setup_organization(xdmod_init_json["organization"])

            print("Create the file share database")

            cnx = connect_to_db(xdmod_init_json["database"])
            create_file_share_db(cnx)
            cnx.commit()
            cnx.close()

        print("set server_root in /etc/httpd/conf/httpd.conf")
        # replace:
        #    ServerName .*$
        # with:
        #    ServerName {xdmod_init_json["server-name"]}}
        if os.path.isfile("/etc/httpd/conf/httpd.conf"):
            with open("/etc/httpd/conf/httpd.conf", encoding="utf-8") as file:
                httpd_conf = file.readlines()
            index = 0
            while index < len(httpd_conf):
                if "ServerName" in httpd_conf[index]:
                    if "server_name" in xdmod_init_json:
                        httpd_conf[
                            index
                        ] = f"ServerName {xdmod_init_json['server_name']}\n"
                    else:
                        httpd_conf[index] = "ServerName localhost\n"
                index += 1
            with open("/etc/httpd/conf/httpd.conf", "w", encoding="utf-8") as file:
                for line in httpd_conf:
                    file.write(line)

        print("   Ingesting resources")
        os.popen("/usr/share/xdmod/tools/etl/etl_overseer.php -p ingest-organizations")
        os.popen("/usr/share/xdmod/tools/etl/etl_overseer.php -p ingest-resource-types")
        os.popen("/usr/share/xdmod/tools/etl/etl_overseer.php -p ingest-resources")

        cnx = connect_to_db(xdmod_init_json["database"])

        os.system("tar -czf /etc/xdmod/etc_xdmod.tgz /etc/xdmod/*")
        os.system("base64 /etc/xdmod/etc_xdmod.tgz > /etc/xdmod/etc_xdmod.b64")
        write_file_to_db(cnx.cursor(), "/etc/xdmod/etc_xdmod.b64", "etc-xdmod")
        os.system("rm /etc/xdmod/etc_xdmod.tgz")
        os.system("rm /etc/xdmod/etc_xdmod.b64")

        cnx.commit()
        cnx.close()

        # This is just to add some time for manual intervention
        time.sleep(600)


main()
