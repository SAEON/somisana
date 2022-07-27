from postgis import connect

sql_path = 'cli/load/postgis/sql/coordinates.sql'

# Setup the materialized view of coordinates
# This view should never need refreshing
def create_view():
    cursor = connect().cursor()
    cursor.execute("select count(*) > 0 from pg_matviews where matviewname = 'coordinates';")
    indexed = cursor.fetchall()[0][0]
    
    if not indexed:
      schema = open(sql_path, 'r')
      schemaSql = schema.read()
      schema.close()
      cursor = connect().cursor()
      cursor.execute(schemaSql)