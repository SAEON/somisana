from postgis import connect

sql_path = 'src/cli/load/postgis/sql/models.sql'

# Setup view that summarizes models
def setup():
    schema = open(sql_path, 'r')
    schemaSql = schema.read()
    schema.close()
    cursor = connect().cursor()
    cursor.execute(schemaSql)