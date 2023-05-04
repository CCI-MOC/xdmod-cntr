"""
Some reusable database functions
"""
import os
import mysql.connector


def exec_fetchone(cursor, sql_stmt, params=None):
    """executes the sql stmt and fetches the first one in the result list"""
    cursor.execute(sql_stmt, params)
    result = cursor.fetchone()
    return result[0]


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


def fetch_file_from_db(cursor, script):
    """As a work-a-round for RWM, share config files though the database"""
    print(f"write {script} file_share_db")
    data = exec_fetchall(
        cursor,
        "select file_name, file_data from file_share_db.file where script=%s",
        (script,),
    )

    if data and isinstance(data, list):
        rec = data[0]
        file = rec[0]
        os.makedirs(os.path.dirname(file), exist_ok=True)
        with open(file, "wb+") as file_from_db:
            file_from_db.write(rec[1])


def save_file_to_db(cursor, filename, script):
    """As a work-a-round for RWM, share config files though the database"""
    # it is ok if the file doesn't as the clouds.yaml is possibly empty or manually updated
    if os.path.isfile(filename):
        print(f" Writing {filename} to db")
        with open(filename, "rb") as file:
            file_contents = file.read()
            count = moc_db.exec_fetchone(
                cursor,
                "select count(*) from file_share_db.file where script=%s",
                (script,),
            )
            if count == 0:
                cursor.execute(
                    "insert into file_share_db.file \
                        (script, file_name, file_data) \
                     values \
                        (%s,%s,%s)",
                    (script, filename, file_contents),
                )
            else:
                cursor.execute(
                    "update file_share_db.file \
                     set file_name=%s, file_data=%s where script=%s",
                    (filename, file_contents, script),
                )


def db_exist(cursor, db_name):
    """This returns true if the db_name database exists"""
    result = exec_fetchall(cursor, "show databases", None)
    for database in result:
        if database["Database"] == db_name:
            return True
    return False
