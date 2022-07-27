from curses.ascii import NUL
import psycopg2
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME

_connection_ = NUL

# Connect to postgres
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
    print('Initialising PostGIS schema and database')
    sql_path = 'postgis/schema.sql'
    schema = open(sql_path, 'r')
    schemaSql = schema.read()
    schema.close()
    cursor = connect().cursor()
    cursor.execute(schemaSql)