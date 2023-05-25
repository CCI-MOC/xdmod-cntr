""" This is to test the basic functions of """
import pytest
import json
import process_hierarchy
import delete_hierarchy_db
import get_users_from_keycloak

# need to modk process_hierarchy
dataset = {
    # empty dataset
    "0": {
        "coldfront_data": [],
        "keycloak_data": [],
        "cli_args": {"output_directory": "./test/data"},
        "hierarchy.csv": [],
        "group.csv": [],
        "pi2project.csv": [],
        "names.csv": [],
    },
    # dataset 2 pis 3 projets
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
        "cli_args": {"output_directory": "./test/data"},
        "hierarchy.csv": [
            '"3","Some University",\n',
            '"4","Some University - engineering","3"\n',
            '"8","Some University - other","3"\n',
            '"5","R B","4"\n',
            '"9","J G","8"\n',
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
    # dataset 1 pi 1 project subset of ("1" dataset 2 pis 3 projets)
    "2": {
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
        ],
        "cli_args": {},
        "hierarchy.csv": [
            '"3","Some University",\n',
            '"4","Some University - engineering","3"\n',
            '"5","R B","4"\n',
        ],
        "group.csv": [
            '"Test Project 1-ff0e78e", "5"\n',
        ],
        "names.csv": [
            '"Test Project 1-ff0e78e", , "Test-Project-1 - Test Project 1-ff0e78e"\n',
        ],
        "pi2project.csv": [
            '"Test Project 1-ff0e78e", "Test Project 1-ff0e78e", "nerc_openstack"\n',
        ],
    },
}


def test_empty_dataset(mocker):
    delete_hierarchy_db.delete_db()
    ds = dataset["0"]
    mocker.patch(
        "get_users_from_keycloak.get_coldfront_data", return_value=ds["coldfront_data"]
    )
    mocker.patch(
        "get_users_from_keycloak.get_keycloak_data", return_value=ds["keycloak_data"]
    )
    mocker.patch("process_hierarchy.get_args", return_value=ds["cli_args"])
    process_hierarchy.main()
    output = {}
    for filename in ["hierarchy.csv", "group.csv", "pi2project.csv", "names.csv"]:
        with open(filename, "r", encoding="utf-8") as file:
            output[filename] = file.readlines()
        assert output[filename] == ds[filename]


def test_2PIs_3Projects(mocker):
    delete_hierarchy_db.delete_db()
    ds = dataset["1"]
    mocker.patch(
        "get_users_from_keycloak.get_coldfront_data", return_value=ds["coldfront_data"]
    )
    mocker.patch(
        "get_users_from_keycloak.get_keycloak_data", return_value=ds["keycloak_data"]
    )
    mocker.patch("process_hierarchy.get_args", return_value=ds["cli_args"])
    process_hierarchy.main()
    output = {}
    for filename in ["hierarchy.csv", "group.csv", "pi2project.csv", "names.csv"]:
        with open(filename, "r", encoding="utf-8") as file:
            output[filename] = file.readlines()
        assert output[filename] == ds[filename]


def test_removal_project_and_pi(mocker):
    delete_hierarchy_db.delete_db()
    for ds_id in ["1", "2"]:
        ds = dataset[ds_id]
        mocker.patch(
            "get_users_from_keycloak.get_coldfront_data",
            return_value=ds["coldfront_data"],
        )
        mocker.patch(
            "get_users_from_keycloak.get_keycloak_data",
            return_value=ds["keycloak_data"],
        )
        mocker.patch("process_hierarchy.get_args", return_value=ds["cli_args"])
        process_hierarchy.main()
        output = {}
        for filename in ["hierarchy.csv", "group.csv", "pi2project.csv", "names.csv"]:
            with open(filename, "r", encoding="utf-8") as file:
                output[filename] = file.readlines()
            assert output[filename] == ds[filename]
