import psycopg2
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME

# Connect to postgres
connection = psycopg2.connect(
    host=PG_HOST,
    port=PG_PORT,
    database=PG_DB,
    user=PG_USERNAME,
    password=PG_PASSWORD
)

connection.autocommit = True

# Setup PostGIS schema and WMS views
schema = open('src/sql/schema.sql', 'r')
schemaSql = schema.read()
schema.close()
salinityView = open('src/sql/wms-abf-salinity.sql', 'r')
salinityViewSql = salinityView.read()
salinityView.close()
temperatureView = open('src/sql/wms-abf-temperature.sql', 'r')
temperatureViewSql = temperatureView.read()
temperatureView.close()

cursor = connection.cursor()
cursor.execute(schemaSql)
cursor.execute(salinityViewSql)
cursor.execute(temperatureViewSql)
print('PostGIS schema (re)initialized')

# Apply schema.sql to the postgis server