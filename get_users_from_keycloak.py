import json
import logging
import requests
from requests.auth import HTTPBasicAuth

logger = logging.getLogger()


def get_client_token():
    client_token = None
    token_url = "<KEYCLOAK URL>/auth/realms/mss/protocol/openid-connect/token"

    try:
        r = requests.post(
            token_url,
            data={"grant_type": "client_credentials"},
            auth=HTTPBasicAuth("<PUT CLIENT ID HERE>", "<PUT CLIENT SECRET HERE>"),
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


session = requests.session()
headers = {
    "Authorization": ("Bearer %s" % get_client_token()),
    "Content-Type": "application/json",
}
session.headers.update(headers)

users = session.get("<KEYCLOAK URL>/auth/admin/realms/mss/users").json()

with open("keycloak_data.json", "w") as f:
    json.dump(users, f)
