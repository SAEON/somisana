from postgis import connect

"""
Update the coordinates table whenever a
new model is used. The assumption is that
once a model is run once, the grid is fixed
in terms of XY and doesn't need further
updates
"""
def create_view(model):
    cursor = connect().cursor()
    cursor.execute("""
      select 1 where exists ( select * from public.models where name = %s )
    """, (model, ))
    exists = not len(cursor.fetchall()) == 0

    if not exists:
      raise Exception('Cannot refresh coordinates for a model that doesn\'t exist')
    
    with open('cli/load/coordinates/coordinates.sql', 'r') as file:
      sql = file.read()
      cursor = connect().cursor()
      cursor.execute(sql, (model, ))