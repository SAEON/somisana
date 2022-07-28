from curses.ascii import NUL
import psycopg2
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME

_connection_ = NUL

CREATE_SQL_PATH = 'postgis/schema.sql'
DROP_SQL_PATH = 'postgis/drop-schema.sql'


def exe_sql_file(path):
    with open(path, 'r') as file:
        sql = file.read()
        cursor = connect().cursor()
        cursor.execute(sql)


def connect():
    global _connection_
    if not _connection_:
        _connection_ = psycopg2.connect(
            host=PG_HOST,
            port=PG_PORT,
            database=PG_DB,
            user=PG_USERNAME,
            password=PG_PASSWORD
        )
        _connection_.autocommit = True
    return _connection_


def setup():
    print('\n*************************************\n(Re)creating the SOMISANA database!!!\n*************************************\n')
    exe_sql_file(CREATE_SQL_PATH)


def drop():
    print('\n*************************************\nDropping the SOMISANA the database!!!\n*************************************\n')
    exe_sql_file(DROP_SQL_PATH)
