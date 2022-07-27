from postgis import connect

print('Initialising PostGIS schema and database')

sql_path = 'cli/load/postgis/sql/schema.sql'
schema = open(sql_path, 'r')
schemaSql = schema.read()
schema.close()
cursor = connect().cursor()
cursor.execute(schemaSql)