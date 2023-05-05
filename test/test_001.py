""" This is to test the basic functions of """
import pytest
import json
import process_hierarchy
import delete_hierarchy_db
import pprint

# need to modk process_hierarchy
dataset = {
    "0": {
        "coldfront_data": [],
        "keycloak_data": [],
        "hierarchy.csv": ['"1","unknown",\n', '"2","unknown","1"\n'],
        "group.csv": [],
        "pi2project.csv": [],
        "names.csv": [],
    },
    "1": {
        "coldfront_data": [
            {
                "id": 1,
                "project": {
                    "id": 11,
                    "title": "Test-Project-1",
                    "pi": "rbb@some.edu",
                    "description": "Experiment to run Autodesk Maya on GPU node",
                    "field_of_science": "Visualization, Graphics, and Image Processing",
                    "status": "New",
                },
                "description": None,
                "resource": {"name": "NERC", "resource_type": "OpenStack"},
                "status": "Active",
                "attributes": {
                    "Allocated Project ID": "2e68e6bf3ba84d96b77ff9cf8f1fffff",
                    "Allocated Project Name": "Test Project 1-ff0e78e",
                },
            },
            {
                "id": 2,
                "project": {
                    "id": 12,
                    "title": "Test-Project-2",
                    "pi": "jim@some.edu",
                    "description": "Experiment to run Autodesk Maya on GPU node",
                    "field_of_science": "Visualization, Graphics, and Image Processing",
                    "status": "New",
                },
                "description": None,
                "resource": {"name": "NERC", "resource_type": "OpenStack"},
                "status": "Active",
                "attributes": {
                    "Allocated Project ID": "2e68e6bf3ba84d96b77ff9cf8f2fffff",
                    "Allocated Project Name": "Test Project 2-ff0e78e",
                },
            },
            {
                "id": 3,
                "project": {
                    "id": 13,
                    "title": "Test-Project-3",
                    "pi": "jim@some.edu",
                    "description": "Experiment to run Autodesk Maya on GPU node",
                    "field_of_science": "Visualization, Graphics, and Image Processing",
                    "status": "New",
                },
                "description": None,
                "resource": {"name": "NERC-OCP", "resource_type": "OpenShift"},
                "status": "Active",
                "attributes": {
                    "Allocated Project ID": "test-project-3",
                    "Allocated Project Name": "test-project-3",
                },
            },
        ],
        "keycloak_data": [
            {
                "id": "7c6a4bea-37f4-46a3-8c52-4a93731fffff",
                "createdTimestamp": 1672154253164,
                "username": "rbb@some.edu",
                "enabled": True,
                "totp": False,
                "emailVerified": True,
                "firstName": "R",
                "lastName": "B",
                "email": "rbb@some.edu",
                "attributes": {
                    "cilogon_idp_name": ["Some University"],
                    "mss_research_domain": ["engineering"],
                },
                "disableableCredentialTypes": [],
                "requiredActions": [],
                "notBefore": 0,
                "access": {
                    "manageGroupMembership": True,
                    "view": True,
                    "mapRoles": True,
                    "impersonate": True,
                    "manage": True,
                },
            },
            {
                "id": "7c6a4bea-37f4-46a3-8c52-4a93731fffff",
                "createdTimestamp": 1672154253164,
                "username": "jim@some.edu",
                "enabled": True,
                "totp": False,
                "emailVerified": True,
                "firstName": "J",
                "lastName": "G",
                "email": "jim@some.edu",
                "attributes": {
                    "cilogon_idp_name": ["Some University"],
                    "mss_research_domain": ["other"],
                },
                "disableableCredentialTypes": [],
                "requiredActions": [],
                "notBefore": 0,
                "access": {
                    "manageGroupMembership": True,
                    "view": True,
                    "mapRoles": True,
                    "impersonate": True,
                    "manage": True,
                },
            },
        ],
        "hierarchy.csv": [
            '"1","unknown",\n',
            '"3","Some University",\n',
            '"2","unknown","1"\n',
            '"4","Some University - engineering","3"\n',
            '"8","Some University - other","3"\n',
            '"5","rbb@some.edu","4"\n',
            '"9","jim@some.edu","8"\n',
        ],
        "group.csv": [
            '"Test Project 1-ff0e78e", "5"\n',
            '"Test Project 2-ff0e78e", "9"\n',
            '"test-project-3", "9"\n',
        ],
        "names.csv": [
            '"Test Project 1-ff0e78e", , "Test-Project-1 - Test Project 1-ff0e78e"\n',
            '"Test Project 2-ff0e78e", , "Test-Project-2 - Test Project 2-ff0e78e"\n',
            '"test-project-3", , "Test-Project-3 - test-project-3"\n',
        ],
        "pi2project.csv": [
            '"Test Project 1-ff0e78e", "Test Project 1-ff0e78e", "nerc_openstack"\n',
            '"Test Project 2-ff0e78e", "Test Project 2-ff0e78e", "nerc_openstack"\n',
        ],
    },
}


def test_000(mocker):
    ds = dataset["0"]
    mocker.patch(
        "process_hierarchy.get_coldfront_data", return_value=ds["coldfront_data"]
    )
    mocker.patch(
        "process_hierarchy.get_all_keycloak_data", return_value=ds["keycloak_data"]
    )
    delete_hierarchy_db.delete_db()
    process_hierarchy.main()
    output = {}
    for filename in ["hierarchy.csv", "group.csv", "pi2project.csv", "names.csv"]:
        with open(filename, "r", encoding="utf-8") as file:
            output[filename] = file.readlines()
        assert output[filename] == ds[filename]


def test_001(mocker):
    ds = dataset["1"]
    mocker.patch(
        "process_hierarchy.get_coldfront_data", return_value=ds["coldfront_data"]
    )
    mocker.patch(
        "process_hierarchy.get_all_keycloak_data", return_value=ds["keycloak_data"]
    )
    delete_hierarchy_db.delete_db()
    process_hierarchy.main()
    output = {}
    for filename in ["hierarchy.csv", "group.csv", "pi2project.csv", "names.csv"]:
        with open(filename, "r", encoding="utf-8") as file:
            output[filename] = file.readlines()
        assert output[filename] == ds[filename]
    # assert False, print("%s", pprint.pformat(output, indent=4, width=120))
    # check files
