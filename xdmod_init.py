#!/usr/bin/python3
""" Python script to intialize xdmod """
import os
import shutil
import pexpect
import time
import json
import yaml
import mysql.connector
import pprint


def xdmod_setup_admin_account(admin_account):
    xdmod_admin_account_json = {
        "cmd": "xdmod-setup",
        "do_list": [
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ", "resp": "5"},
            {"prompt": "Username: ", "resp": admin_account["admin_username"]},
            {"prompt": "Password: ", "resp": admin_account["admin_password"]},
            {"prompt": "\(confirm\) Password: ", "resp": admin_account["admin_password"]},
            {"prompt": "First name: ", "resp": admin_account["first_name"]},
            {"prompt": "Last name: ", "resp": admin_account["last_name"]},
            {"prompt": "Email address: ", "resp": admin_account["email_address"]},
            {"prompt": "Press ENTER to continue.", "resp": ""},
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ", "resp": "q", "timeout": 600},
        ],
    }
    run_pexpect_json(xdmod_admin_account_json)


def xdmod_setup_general_settings(general_settings):
    xdmod_general_settings_json = {
        "cmd": "xdmod-setup",
        "do_list": [
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ", "resp": "1"},
            {"prompt": "Site Address: \[.*\]", "resp": general_settings["site_address"]},
            {"prompt": "Email Address:", "resp": general_settings["contact_email_address"]},
            {"prompt": "Chromium Path: \[.*\]", "resp": ""},
            {"prompt": "Center Logo Path:", "resp": general_settings["center_logo_path"]},
            {"prompt": "Enable Dashboard Tab \(on, off\)\? \[off\]", "resp": general_settings["enable_dashboard"]},
            {"prompt": "Overwrite config file '/etc/xdmod/portal_settings.ini' \(yes, no\)\? \[yes\]", "resp": ""},
            {"prompt": "Press ENTER to continue.", "resp": ""},
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ", "resp": "q"},
        ],
    }
    run_pexpect_json(xdmod_general_settings_json)


def xdmod_setup_organization(organization):
    xdmod_setup_organization_json = {
        "cmd": "xdmod-setup",
        "do_list": [
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ", "resp": "3"},
            {"prompt": "Organization Name: ", "resp": organization["name"]},
            {"prompt": "Organization Abbreviation: ", "resp": organization["abbreviation"]},
            {"prompt": "Overwrite config file '/etc/xdmod/organization.json' \(yes, no\)\? \[.*\]", "resp": "yes"},
            {"prompt": "Press ENTER to continue.*", "resp": ""},
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ", "resp": "q", "timeout": 600},
        ],
    }
    run_pexpect_json(xdmod_setup_organization_json)


def xdmod_setup_database(database):
    xdmod_setup_databases_json = {
        "cmd": "xdmod-setup",
        "do_list": [
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ", "resp": "2"},
            {"prompt": "DB Hostname or IP: \[.*\] ", "resp": database["host"]},
            {"prompt": "DB Port: \[.*\] ", "resp": ""},
            {"prompt": "DB Username: \[.*\] ", "resp": "xdmod"},
            {"prompt": "DB Password: ", "resp": database["xdmod_password"]},
            {"prompt": "\(confirm\) DB Password: ", "resp": database["xdmod_password"]},
            {"prompt": "DB Admin Username: \[root\] ", "resp": ""},
            {"prompt": "DB Admin Password: ", "resp": database["admin_password"]},
            {"prompt": "\(confirm\) DB Admin Password: ", "resp": database["admin_password"]},
            {
                "prompt": "Database `mod_shredder` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\] ",
                "resp": "yes",
                "timeout": 600,
                "sleep": 30,
            },
            {"prompt": "Database `mod_hpcdb` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]", "resp": "yes", "timeout": 600, "sleep": 30},
            {"prompt": "Database `moddb` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]", "resp": "yes", "timeout": 600, "sleep": 30},
            {"prompt": "Database `modw` already exists..*\r\nDrop and recreate database \(yes, no\)\? \[.*\]", "resp": "yes", "timeout": 600, "sleep": 30},
            {
                "prompt": "Database `modw_aggregates` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]",
                "resp": "yes",
                "timeout": 600,
                "sleep": 30,
            },
            {
                "prompt": "Database `modw_filters` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]",
                "resp": "yes",
                "timeout": 600,
                "sleep": 30,
            },
            {"prompt": "Database `mod_logger` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]", "resp": "yes", "timeout": 600, "sleep": 30},
            {"prompt": "Overwrite config file '/etc/xdmod/portal_settings.ini' \(yes, no\)\? \[.*\]", "resp": "yes"},
            {"prompt": "Press ENTER to continue.", "resp": ""},
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ", "resp": "q", "timeout": 1200},  # not sure why this takes so long!!!
        ],
    }
    run_pexpect_json(xdmod_setup_databases_json)


def xdmod_setup_resource(resource):
    xdmod_setup_resource_json = {
        "cmd": "xdmod-setup",
        "do_list": [
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\):", "resp": "4"},
            {"prompt": "Select an option \(1, 2, s\): ", "resp": "1"},
            {"prompt": "Resource Name: ", "resp": resource["name"]},
            {"prompt": "Formal Name:", "resp": resource["formal_name"]},
            {"prompt": "Resource Type \(.*\): \[.*\] ", "resp": resource["type"]},
            {"prompt": "How many nodes does this resource have\? ", "resp": "0"},
            {"prompt": "How many total processors \(cpu cores\) does this resource have\? ", "resp": "0"},
            {"prompt": "Select an option \(1, 2, s\): ", "resp": "s"},
            {"prompt": "Overwrite config file '/etc/xdmod/resources.json' \(yes, no\)\? \[yes\] ", "resp": "yes"},
            {"prompt": "Press ENTER to continue. ", "resp": ""},
            {"prompt": "Overwrite config file '/etc/xdmod/resource_specs.json' \(yes, no\)\? \[yes\] ", "resp": "yes"},
            {"prompt": "Press ENTER to continue. ", "resp": ""},
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\):", "resp": "q", "timeout": 600},
        ],
    }
    run_pexpect_json(xdmod_setup_resource_json)


def run_pexpect_json(pexpect_json):
    setup = pexpect.spawn(pexpect_json["cmd"])
    print(f"running comand {pexpect_json['cmd']}")
    for prompt_resp in pexpect_json["do_list"]:
        print(f"{prompt_resp['prompt']}\n")
        t = 30
        if "timeout" in prompt_resp:
            t = prompt_resp["timeout"]
        try:
            setup.expect(prompt_resp["prompt"], timeout=t)
        except Exception as e:
            print(f"{setup.before} -->  {prompt_resp['resp']}")
            print(str(e))
            exit(1)
        nap_time = 0.2
        if "sleep" in prompt_resp:
            nap_time = prompt_resp["sleep"]
        time.sleep(nap_time)
        setup.sendline(prompt_resp["resp"])


def exec_sql(cursor, sql_stmt, params, error_msg):
    try:
        cursor.execute(sql_stmt, params)
    except Exception as e:
        print(f"{str(e)} \n {error_msg}")
        exit(1)


def exec_fetchall(cursor, sql_stmt, params, error_msg):
    exec_sql(cursor, sql_stmt, params, error_msg)
    try:
        result = cursor.fetchall()
    except Exception as e:
        print(f"{str(e)} \n {error_msg}")
        exit(1)
    return result


def exec_fetchone(cursor, sql_stmt, params, error_msg):
    exec_sql(cursor, sql_stmt, params, error_msg)
    try:
        result = cursor.fetchone()
    except Exception as e:
        print(f"{str(e)} \n {error_msg}")
        exit(1)
    return result


def initialize_database(database, db_list):
    host = database["host"]
    admin_acct = "root"
    admin_pass = database["admin_password"]
    acct = "xdmod"
    password = database["xdmod_password"]
    # This part should be done in xdmod-setup
    try:
        cnx = mysql.connector.connect(host=host, user=admin_acct, password=admin_pass)
    except mysql.connector.Error as err:
        if err.errno == err.ER_ACCESS_DENIED_ERROR:
            print("Something is wrong with your user name or password")
        elif err.errno == err.ER_BAD_DB_ERROR:
            print("Database does not exist")
        else:
            print(err)
    print("Connected to database ")
    cursor = cnx.cursor()

    user_count = exec_fetchone(
        cursor, "select count(*) from mysql.user where mysql.user.host=%s and mysql.user.user=%s", (host, acct), "failed to fetch user count(1)"
    )

    print(f"    user_count(1) = {user_count}")
    if user_count == 0:
        exec_sql(cursor, f"create user %s@%s identified by %s", (acct, host, password), f"Failed creating user 1: {acct}@{host}/{password}")

    user_count = exec_fetchone(
        cursor, "select count(*) from mysql.user where mysql.user.host=%s and mysql.user.user=%s", ("%", acct), "failed to fetch user count(2)"
    )
    print(f"    user_count(2) = {user_count}")
    if user_count == 0:
        exec_sql(cursor, f"create user %s@%s identified by %s", (acct, "%", password), f"Failed creating user 1: {acct}@'%'/{password}")

    exec_sql(cursor, "set global sql_mode=''", None, "Failed to set global sql_mode")
    exec_sql(cursor, "set local sql_mode=''", None, "Failed to set local sql_mode")

    print("sql mode set")
    database_names = exec_fetchall(cursor, "select schema_name from information_schema.schemata", None, "Failed fetching databases")

    print(f"database list: ")
    pprint.pprint(database_names)
    for dbname in db_list:
        if dbname not in database_names:
            exec_sql(cursor, f"create database {dbname} default character set 'utf8'", None, f"Failed creating database: {dbname}")
        exec_sql(cursor, f"grant all on {dbname}.* to %s@%s identified by %s", (acct, host, password), f"Failed granting {acct}@{host} on database {dbname}")
        exec_sql(cursor, f"grant all on {dbname}.* to %s@%s identified by %s", (acct, "%", password), f"Failed granting {acct}@'%' on database {dbname}")

    exec_sql(cursor, "flush privileges", None, f"Failed to flush privileges")

    # check to see if there are any table defined in any of the schemas
    table_count = 0
    for dbname in db_list:
        table_count += exec_fetchone(cursor, "select count(*) from information_schema.tables where table_schema=%s", (dbname,), "Unable to get table count")

    cnx.close()
    print(f"table_count = {table_count}")
    return table_count


def main():
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

        # this only exists in development
        if os.path.isdir("/mnt/xdmod_src") and len(os.listdir("/mnt/xdmod_src")) < 5:
            print(" empty directory xdmod_src - inializing")
            os.popen("cp -r /usr/share/xdmod/* /mnt/xdmod_src")
            nap_time = 30

        if os.path.isfile("/root/xdmod_init.json"):
            print(" copy over xdmod_init.json")
            os.popen("cp /root/xdmod_init.json /mnt/xdmod_conf")
            nap_time = 30

        if nap_time > 0:
            print(f" wait {nap_time} seconds for buffers to flush ")
            time.sleep(nap_time)
        return

    if os.path.isfile("/etc/xdmod/xdmod_init.json"):
        print("xdmod_init.json found, attempting to initialize xdmod ")
        with open("/etc/xdmod/xdmod_init.json") as json_file:
            xdmod_init_json = json.load(json_file)
            print("Intializing general settings")
            xdmod_setup_general_settings(xdmod_init_json["general_settings"])

            print("Databases:")
            db_list = ["mod_shredder", "mod_hpcdb", "moddb", "modw", "modw_aggregates", "modw_filters", "mod_logger", "modw_cloud"]
            table_count = initialize_database(xdmod_init_json["database"], db_list)
            print(f"   table_count = {table_count}")

            if table_count == 0:
                print("    seting up databases (and resources)")
                xdmod_setup_database(xdmod_init_json["database"])

                print("Administrative Account:")
                xdmod_setup_admin_account(xdmod_init_json["admin_account"])

            resource_dict = {}
            if os.path.isfile("/etc/xdmod/resources.json"):
                with open("/etc/xdmod/resrouces.json") as resource_file:
                    resources = json.load(resource_file)
                    for r in resources:
                        resource_dict[r[resource]].r
            cloud_conf_dict = {}
            if os.path.isfile("/root/xdmod_data/.config/openstack/cloud.yaml"):
                with open("/root/xdmod_data/.config/openstack/cloud.yaml") as cloud_conf_file:
                    cloud_conf_dict = yaml.load(cloud_conf_file)

            for resource in xdmod_init_json["resource"]:
                if resource not in resource_dict:
                    xdmod_setup_resource(resource)  # this has the side effect of updating the resources.json config filef
                if resource not in cloud_conf_dict and resource["auth_url"]:
                    # find the app creds or username/password
                    if os.path.isfile(f"/root/resource/{resource}/client_id") and os.path.isfile(f"/root/resource/{resource}/client_secret"):
                        with open(f"/root/resource/{resource}/client_id") as f:
                            client_id = f.readline()
                        with open(f"/root/resource/{resource}/client_secret") as f:
                            client_secret = f.readline()
                        cloud_conf_dict.append(
                            {
                                resource: {
                                    "auth": {
                                        "auth_url": resource_dict["auth_url"],
                                        "application_credential_id": client_id,
                                        "application_credential_secret": client_secret,
                                    },
                                    "interface": "public",
                                    "identity_api_version": 3,
                                    "auth_type": "v3applicationcredential",
                                }
                            }
                        )
                        with open("/root/xdmod_data/.config/openstack/cloud.yaml") as f:
                            yaml.dump(cloud_conf_dict, "/root/xdmod_data/.config/openstack/cloud.yaml")
                if not os.path.isdir(f"/root/xdmod_data/{resource}"):
                    os.popen(f"mkdir /root/xdmod_data/{resource}")

            print(" Organization: ")
            if not os.path.isfile("/etc/xdmod/organization.json"):
                # Using the presence of the organization.json file instead of searching for the organization in the database(s)
                print("    No organization found, initilizing organization")
                xdmod_setup_organization(xdmod_init_json["organization"])
                os.popen("/usr/share/xdmod/tools/etl/etl_overseer.php -p ingest-organizations")

        print("   Ingesting resources")
        os.popen("/usr/share/xdmod/tools/etl/etl_overseer.php -p ingest-organizations")
        os.popen("/usr/share/xdmod/tools/etl/etl_overseer.php -p ingest-resource-types")
        os.popen("/usr/share/xdmod/tools/etl/etl_overseer.php -p ingest-resources")

        print("  Ingesting Sample data")
        os.popen("xdmod-shredder --debug -f openstack -d /root/test/openstack -r xdmodtest")
        os.popen("xdmod-ingestor ")


main()
