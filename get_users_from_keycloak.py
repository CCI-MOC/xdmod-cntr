import json
import logging
import requests
from requests.auth import HTTPBasicAuth

logger = logging.getLogger()


def get_client_token(keycloak_url, keycloak_client_id, keycloak_client_secret):
    client_token = None
    token_url = f"{keycloak_url}/auth/realms/mss/protocol/openid-connect/token"

    try:
        r = requests.post(
            token_url,
            data={"grant_type": "client_credentials"},
            auth=HTTPBasicAuth(keycloak_client_id, keycloak_client_secret),
        )

        token_response = r.json()
        client_token = token_response.get("access_token", None)

    except requests.exceptions.RequestException as re:
        logger.error(
            "An error occurred communicating with the server "
            f"while trying to get the client_token. Error: {re}"
        )

    except requests.exceptions.JSONDecodeError as decode_error:
        logger.debug(
            "An error occurred decoding the client token "
            f" returned by the server. Error: {decode_error}"
        )

    return client_token


def get_keycloak_data(keycloak_info):
    session = requests.session()
    headers = {
        "Authorization": (
            "Bearer %s"
            % get_client_token(
                keycloak_info["url"],
                keycloak_info["client_id"],
                keycloak_info["client_secret"],
            )
        ),
        "Content-Type": "application/json",
    }
    session.headers.update(headers)

    users = session.get(f"{keycloak_info['url']}/auth/admin/realms/mss/users").json()
    return users


def get_coldfront_data(keycloak_info, coldfront_info):
    session = requests.session()
    headers = {
        "Authorization": (
            "Bearer %s"
            % get_client_token(
                keycloak_info["url"],
                keycloak_info["client_id"],
                keycloak_info["client_secret"],
            )
        ),
        "Content-Type": "application/json",
    }
    session.headers.update(headers)

    allocations = session.get(f"{coldfront_info['url']}/api/allocations/").json()
    return allocations
