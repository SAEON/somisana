from postgis import connect

sql_path = 'cli/load/postgis/sql/metadata.sql'

# Setup view that summarizes models
def setup():
    schema = open(sql_path, 'r')
    schemaSql = schema.read()
    schema.close()
    cursor = connect().cursor()
    cursor.execute(schemaSql)