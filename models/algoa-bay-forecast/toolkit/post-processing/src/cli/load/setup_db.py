from postgis import connect

# Setup PostGIS schema and WMS views
def setup():
    schema = open('src/cli/load/sql/schema.sql', 'r')
    schemaSql = schema.read()
    schema.close()

    cursor = connect().cursor()
    cursor.execute(schemaSql)
    print('PostGIS schema (re)initialized')