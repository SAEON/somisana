from postgis import connect

sql_path = 'cli/load/metadata.sql'

# Setup view that summarizes models
def create_view(model):
    schema = open(sql_path, 'r')
    schemaSql = schema.read()
    schema.close()
    cursor = connect().cursor()
    cursor.execute(schemaSql)