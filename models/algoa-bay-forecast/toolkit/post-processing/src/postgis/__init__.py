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

# Setup PostGIS schema and WMS views
def setup():
    schema = open('src/postgis/sql/schema.sql', 'r')
    schemaSql = schema.read()
    schema.close()
    salinityView = open('src/postgis/sql/wms-abf-salinity.sql', 'r')
    salinityViewSql = salinityView.read()
    salinityView.close()
    temperatureView = open('src/postgis/sql/wms-abf-temperature.sql', 'r')
    temperatureViewSql = temperatureView.read()
    temperatureView.close()

    cursor = connect().cursor()
    cursor.execute(schemaSql)
    cursor.execute(salinityViewSql)
    cursor.execute(temperatureViewSql)
    print('PostGIS schema (re)initialized')