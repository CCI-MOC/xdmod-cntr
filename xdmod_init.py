#!/usr/bin/python3
""" Python script to intialize xdmod """
import os
import shutil
import pexpect
import time
import mysql.connector
import pprint



def xdmod_setup_admin_account(admin_account):
    xdmod_admin_account_json = {
        "cmd": "xdmod-setup",
        "do_list": [
            {"prompt": "Select an option (1, 2, 3, 4, 5, 6, 7, 8, q): ", "resp": "5"},
            {"prompt": "Username: ", "resp": admin_account["admin_username"]},
            {"prompt": "Password: ", "resp": admin_account["admin_password"]},
            {"prompt": "(confirm) Password: ", "resp": admin_account["admin_password"]},
            {"prompt": "First name: ", "resp": admin_account["first_name"]},
            {"prompt": "Last name: ", "resp": admin_account["last_name"]},
            {"prompt": "Email address: ", "resp": admin_account["email_address"]}
        ]
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
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ", "resp": "q"},
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
            {"prompt": "Database `mod_shredder` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\] ", "resp": "yes"},
            {"prompt": "Database `mod_hpcdb` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]", "resp": "yes"},
            {"prompt": "Database `moddb` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]", "resp": "yes"},
            {"prompt": "Database `modw` already exists..*\r\nDrop and recreate database \(yes, no\)\? \[.*\]", "resp": "yes"},
            {"prompt": "Database `modw_aggregates` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]", "resp": "yes"},
            {"prompt": "Database `modw_filters` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]", "resp": "yes"},
            {"prompt": "Database `mod_logger` already exists.*\r\nDrop and recreate database \(yes, no\)\? \[.*\]", "resp": "yes"},
            {"prompt": "Overwrite config file '/etc/xdmod/portal_settings.ini' \(yes, no\)\? \[.*\]", "resp": "yes"},
            {"prompt": "Press ENTER to continue.", "resp": ""},
            {"prompt": "Select an option \(1, 2, 3, 4, 5, 6, 7, 8, q\): ", "resp": "q"},
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
            {"prompt": "Resource Type \(hpc, htc, dic, grid, cloud, vis, vm, tape, disk, stgrid, us, gateway\): [hpc] ", "resp": resource["type"]},
            {"prompt": "How many nodes does this resource have? ", "resp": "0"},
            {"prompt": "How many total processors \(cpu cores\) does this resource have? ", "resp": "0"},
            {"prompt": "Select an option \(1, 2, s\): ", "resp": "s"},
            {"prompt": "Overwrite config file '/etc/xdmod/resources.json' \(yes, no\)\? \[yes\] ", "resp": "yes"},
            {"prompt": "Press ENTER to continue. ", "resp": ""},
            {"prompt": "Overwrite config file '/etc/xdmod/resource_specs.json' \(yes, no\)\? \[yes\] ", "resp": "yes"},
            {"prompt": "Press ENTER to continue. ", "resp": ""},
        ],
    }
    run_pexpect_json(xdmod_setup_resource_json)


def run_pexpect_json(pexpect_json):
    setup = pexpect.spawn(pexpect_json["cmd"])
    print(f"running comand {pexpect_json['cmd']}")
    for prompt_resp in pexpect_json["do_list"]:
        print(f"{prompt_resp['prompt']}\n")
        try:
            setup.expect(prompt_resp["prompt"])
        except Exception as e:
            print(f"{setup.before} -->  {prompt_resp['resp']}")
            print(str(e))
            exit(1)
        time.sleep(0.2)
        setup.sendline(prompt_resp["resp"])


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
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("Something is wrong with your user name or password")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print("Database does not exist")
        else:
            print(err)
    print("Connected to database ")
    cursor = cnx.cursor()

    try:
        cursor.execute("select count(*) from mysql.user where mysql.user.host=%s and mysql.user.user=%s", (host, acct))
        user_count = cursor.fetchone()
    except Exception as e:
        print(f"failed to fetch user count")
        exit(1)

    print(f"    user_count(1) = {user_count}")
    if user_count == 0:
        try:
            cursor.execute(f"create user %s@%s identified by %s", (acct, host, password))
        except Exception as e:
            print(f"Failed creating user 1: {acct}@{host}/{password}")
            exit(1)
    try:
        cursor.execute("select count(*) from mysql.user where mysql.user.host=%s and mysql.user.user=%s", ("%", acct))
        user_count = cursor.fetchone()
    except Exception as e:
        print(f"failed to fetch user count")
        exit(1)

    print(f"    user_count(2) = {user_count}")
    if user_count == 0:
        try:
            cursor.execute(f"create user %s@%s identified by %s", (acct, "%", password))
        except Exception as e:
            print(f"Failed creating user 2: {acct}@'%'/{password}")
            exit(1)

    try:
        cursor.execute(f"set global sql_mode=''")
    except Exception as e:
        print("Failed to set global sql_mode")
        exit(1)

    try:
        cursor.execute(f"set local sql_mode=''")
    except Exception as e:
        print("Failed to set local sql_mode")
        exit(1)

    print("sql mode set")
    database_names = []
    try:
        cursor.execute("select schema_name from information_schema.schemata")
        result = cursor.fetchall()
        for db_name in result:
            database_names.append(db_name[0])
    except Exception as e:
        print(f"Failed fetching databases")
        exit(1)

    print(f"database list: ")
    pprint.pprint(database_names)
    for dbname in db_list:

        if dbname not in database_names:
            # create the database
            try:
                cursor.execute(f"create database {dbname} default character set 'utf8'")
            except Exception as e:
                print(f"Failed creating database: {dbname}")
                pprint.pprint(e)
                exit(1)

        # grant all on admin and acct
        try:
            cursor.execute(f"grant all on {dbname}.* to %s@%s identified by %s", (acct, host, password))
        except Exception as e:
            print(f"Failed granting {acct}@{host} on database {dbname}")
            exit(1)

        try:
            cursor.execute(f"grant all on {dbname}.* to %s@%s identified by %s", (acct, "%", password))
        except Exception as e:
            print(f"Failed granting {acct}@'%' on database {dbname}")
            exit(1)

    try:
        cursor.execute("flush privileges")
    except Exception as e:
        print(f"Failed to flush privileges")
        exit(1)

    # check to see if there are any table defined in any of the schemas
    table_count = 0
    for dbname in db_list:
        try:
            cursor.execute("select count(*) from information_schema.tables where table_schema=%s", (dbname,))
        except Exception as e:
            print(f"Failed to get count tables in xdmod's databases: {str(e)}")
            exit(1)
        try:
            table_count += cursor.fetchone()[0]
        except Exception as e:
            print(f"fetchone from cursor failed: {str(e)}")
            exit(1)

    cnx.close()
    print(f"table_count = {table_count}")
    return table_count


def main():

    xdmod_init_json={
        "admin_account": {
            "admin_username": "Admin",
            "admin_password": "pass",
            "first_name": "ad",
            "last_name": "min",
            "eamil_address": "nobody@massopen.cloud"
        },
        "general_settings":{
            "site_address":"xdmod.apps.nerc-shift-0.rc.fas.harvard.edu",
            "contact_email_address": "robbaron@bu.edu",
            "center_logo_path": "",
            "enable_dashboard": "no"
        },
        "organization": { 
            "name":"Mass Open Cloud",
            "abbreviation": "MOC"
        },
        "database": {
            "database_host": "mariadb", 
            "xdmod_password": "pass", 
            "admin_password": "pass"
        },
        "resource":[ 
            { "name": "kaizen", "formal_name": "kaizen", "type": "cloud" }
        ]
    }

    if os.path.isdir("/mnt/xdmod_conf"):
        # This can only be on the first init container
        print("Found /mnt/xdmod* ")
        if len(os.listdir("/mnt/xdmod_conf")) == 0:
            print(" empty directory xdmod_conf found - initializing")
            os.popen("cp -r /etc/xdmod/* /mnt/xdmod_conf")

        # this only exists in development
        if os.path.isdir("/mnt/xdmod_src") and len(os.listdir("/mnt/xdmod_src")) == 0:
            print(" empty directory xdmod_src - inializing")
            os.popen("cp -r /usr/share/xdmod/* /mnt/xdmod_src")
        return
    print("Intializing general settings")
    run_pexpect_json(xdmod_general_settings)

    print("Databases:")
    db_list = ["mod_shredder", "mod_hpcdb", "moddb", "modw", "modw_aggregates", "modw_filters", "mod_logger"]
    table_count = initialize_database(xdmod_init_json["database"], db_list)
    print(f"   table_count = {table_count}")
    init_resources = False
    if table_count == 0:
        print("    seting up databases (and resources)")
        xdmod_setup_database(xdmod_init_json["database"])

        # Using the database initialization instead of searching for each resource in the database and only adding the ones that don't exist
    for resource in xdmod_init_json["resource"]:
        xdmod_setup_resources(resource)
    init_resources = True
    # yet again, should be using the database for this one
    print("Administrative Account:")
    xdmod_setup_admin(xdmod_init_json["admin_account"])

    print(" Organization: ")
    if not os.path.isfile("/etc/xdmod/organizations.json"):
        # Using the presence of the organization.json file instead of searching for the organization in the database(s)
        print("    No organization found, initilizing organization")
        xdmod_setup_organization(xdmod_init_json["organization"]))
        os.popen("/usr/share/xdmod/tools/etl/etl_overseer.php -p ingest-organizations")

    print("Resources: ")
    if init_resources:
        print("   Ingesting resources")
        os.popen("/usr/share/xdmod/tools/etl/etl_overseer.php -p ingest-resource-types")


main()
