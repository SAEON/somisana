from postgis import pool

"""
Update the coordinates table whenever a
new model is used. The assumption is that
once a model is run once, the grid is fixed
in terms of XY and doesn't need further
updates
"""
def upsert(model):    
    with open('cli/load/coordinates/coordinates.sql', 'r') as file:
      sql = file.read()
      with pool().connection() as client:
        client.execute(sql, (model, ))