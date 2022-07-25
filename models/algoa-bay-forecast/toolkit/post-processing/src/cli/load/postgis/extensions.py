from postgis import connect

sql_path = 'src/cli/load/postgis/sql/extensions.sql'

# Setup PostGIS schema and WMS views
def activate():
    schema = open(sql_path, 'r')
    schemaSql = schema.read()
    schema.close()
    cursor = connect().cursor()
    cursor.execute(schemaSql)