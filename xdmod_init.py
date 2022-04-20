#!/usr/bin/python3
""" Python script to intialize xdmod """
import os
import shutil
import pexpect
import time

xdmod_general_settings = {
    "cmd": "xdmod-setup",
    "do_list": [
        {"prompt": "Select an option (1, 2, 3, 4, 5, 6, 7, 8, q): ", "resp": "q"},
        {"prompt": "Site Address: [https://localhost/]", "resp": "http://xdmod.apps...."},
        {"prompt": "Email Address:", "resp": "robbaron@bu.edu"},
        {"prompt": "Chromium Path: [/usr/lib64/chromium-browser/headless_shell]", "resp": ""},
        {"prompt": "Center Logo Path:", "resp": ""},
        {"prompt": "Enable Dashboard Tab (on, off)? [off]", "resp": ""},
        {"prompt": "Overwrite config file '/etc/xdmod/portal_settings.ini' (yes, no)? [yes]", "resp": ""},
        {"prompt": "Press ENTER to continue.", "resp": ""},
        {"prompt": "Select an option (1, 2, 3, 4, 5, 6, 7, 8, q): ", "resp": "q"},
    ],
}


def copy_dir(from_dir, to_dir):
    if not os.path.isdir(from_dir):
        print(f"Error: {from_dir} does not exist")
        exit
    if os.path.isdir(to_dir) and len(os.listdir(to_dir)) < 3:
        shutil.copytree(from_dir, to_dir)


def run_pexpect_json(pexpect_json):
    setup = pexpect.spawn(pexpect_json["cmd"])
    print(f"running comand {pexpect_json['cmd']}")
    for prompt_resp in pexpect_json["do_list"]:
        print(f"   {prompt_resp['prompt']}")
        while not setup.expect("prompt_resp['prompt']"):
            print(f"---> {setup.before}")
        time.sleep(0.1)
        setup.sendline(prompt_resp["resp"])


def xdmod_setup_organization():
    # Select an option (1, 2, 3, 4, 5, 6, 7, 8, q):
    # -> 3
    # Organization Name:
    # -> Mass Open Cloud
    # Organization Abbreviation:
    # -> MOC
    # Overwrite config file '/etc/xdmod/organization.json' (yes, no)? [yes]
    # ->
    # Press ENTER to continue.
    # ->
    # Select an option (1, 2, 3, 4, 5, 6, 7, 8, q):
    # -> q
    return


def xdmod_setup_databases():
    # Select an option (1, 2, 3, 4, 5, 6, 7, 8, q):
    # -> 2
    # DB Hostname or IP: [localhost]
    # -> mariadb
    # DB Port: [3306]
    # ->
    # DB Username: [xdmod]
    # ->
    # DB Password:
    # -> pass
    # (confirm) DB Password:
    # -> pass
    # DB Admin Username: [root]
    # ->
    # DB Admin Password:
    # -> pass
    # (confirm) DB Admin Password:
    # -> pass
    # Database `mod_shredder` already exists.
    # Drop and recreate database (yes, no)? [no]
    # -> yes
    # Database `mod_hpcdb` already exists.
    # Drop and recreate database (yes, no)? [no]
    # -> yes
    # Database `moddb` already exists.
    # Drop and recreate database (yes, no)? [no]
    # -> yes
    # Database `modw` already exists.
    # Drop and recreate database (yes, no)? [no]
    # -> yes
    # Database `modw_aggregates` already exists.
    # Drop and recreate database (yes, no)? [no]
    # -> yes
    # Database `modw_filters` already exists.
    # Drop and recreate database (yes, no)? [no]
    # -> yes
    # Database `mod_logger` already exists.
    # Drop and recreate database (yes, no)? [no]
    # -> yes
    # Overwrite config file '/etc/xdmod/portal_settings.ini' (yes, no)? [yes]
    # ->
    # Press ENTER to continue.
    # ->
    # Select an option (1, 2, 3, 4, 5, 6, 7, 8, q):
    # -> q
    return


# this is just a stub
def xdmod_setup_resources():
    # Select an option (1, 2, 3, 4, 5, 6, 7, 8, q):
    # ->
    # Select an option (1, 2, 3, 4, 5, 6, 7, 8, q):
    # -> q
    return


def main():

    if os.path.isdir("/mnt/xdmod_conf"):
        # This can only be on the first init container
        if len(os.listdir("/mnt/xdmod_conf")) == 0:
            os.popen("cp -r /etc/xdmod/* /mnt/xdmod_conf")

        # this only exists in development
        if os.path.isdir("/mnt/xdmod_src") and len(os.listdir("/mnt/xdmod_src")) == 0:
            os.popen("cp -r /usr/share/xdmod/* /mnt/xdmod_src")
        return

    # if not os.path.isfile("/etc/xdmod/organizations.json"):
    # run_pexpect_json(xdmod_general_settings)
    # xdmod_setup_organization()
    # xdmod_setup_general_settings()
    # xdmod_setup_resources()
    # run /usr/share/xdmod/tools/etl/etl_overseer.php -p ingest-organizations

    # need to peek inside the database and see if there are any databases


main()
