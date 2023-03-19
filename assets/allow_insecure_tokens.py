#!/usr/bin/python3
""" simple script to modify the php code to allow insecure tokens to be used """

import os
import re

# This might not be necessary in the future

# replace:
#    setcookie('xdmod_token', getToken(), 0, '/', '', true, true);
# with:
#    setcookie('xdmod_token', getToken\(\), 0, '/', '', false, false)'
if os.path.isfile("/usr/share/xdmod/libraries/rest.php"):
    with open("/usr/share/xdmod/libraries/rest.php", encoding="utf-8") as file:
        rest_php = file.read().replace(
            "setcookie('xdmod_token', getToken(), 0, '/', '', true, true)",
            "setcookie('xdmod_token', getToken(), 0, '/', '', false, false)",
        )
    with open("/usr/share/xdmod/libraries/rest.php", "w", encoding="utf-8") as file:
        file.write(rest_php)

if os.path.isfile("/usr/share/xdmod/libraries/security.php"):
    """
            $cParams["lifetime"],
            $cParams["path"],
            $cParams['domain'],
    -     true
    +     false
            );
    """
    security_php = None
    with open("/usr/share/xdmod/libraries/security.php", "r", encoding="utf-8") as file:
        security_php = file.read()
        match1_str = re.search(
            r"[ \t]+\$cParams\[\"lifetime\"\],[ \t\n\r\f]*\$cParams\[\"path\"\],[ \t\n\r\f]*\$cParams\['domain'\],[ \t\n\r\f]*(true)[ \t\n\r\f]*\);",
            security_php,
        )
        if match1_str:
            match2_str = re.search(r"true", match1_str.group())
            if match2_str:
                replace_span = (
                    match2_str.span()[0] + match1_str.span()[0],
                    match2_str.span()[1] + match1_str.span()[0],
                )
                begining_str = security_php[: replace_span[0]]
                after_str = security_php[replace_span[1] :]
                security_php = "".join([begining_str, "false", after_str])

    with open("/usr/share/xdmod/libraries/security.php", "w", encoding="utf-8") as file:
        file.write(security_php)
