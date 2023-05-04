import os
import mysql.connector


def exec_fetchone(cursor, sql_stmt, params=None):
    """executes the sql stmt and fetches the first one in the result list"""
    cursor.execute(sql_stmt, params)
    result = cursor.fetchone()
    return result


def exec_fetchall(cursor, sql_stmt, params):
    """executes the sql statmement and fetches all in a list"""
    cursor.execute(sql_stmt, params)
    return cursor.fetchall()


def connect_to_db(database):
    """This just connects to the database and returns the connection"""
    host = database["host"]
    admin_acct = "root"
    admin_pass = database["admin_password"]
    # it is ok if the file doesn't as the clouds.yaml is possibly empty or manually updated
    return mysql.connector.connect(host=host, user=admin_acct, password=admin_pass)


def write_file_from_db(cursor, script):
    """As a work-a-round for RWM, share config files though the database"""
    print(f"write {script} file_share_db")
    data = exec_fetchall(
        cursor,
        "select file_name, file_data from file_share_db.file where script=%s",
        (script,),
    )

    rec = data[0]
    file = rec[0]
    os.makedirs(os.path.dirname(file), exist_ok=True)
    with open(file, "wb+") as fp:
        fp.write(rec[1])


def db_exist(cursor, db_name):
    result = exec_fetchall(cursor, "show databases", None)
    for database in result:
        if database["Database"] == db_name:
            return True
    return False
