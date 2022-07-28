from postgis import connect

"""
Either create the view, or if the view exists, either
refresh the view if it's a new model value, or do nothing.
I couldn't figure out how to parametize the model string value
using the psycog2 module. So instead I'm just checking that the
value exists as a string in the models table. This should be safe
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
      sql = file.read().replace('%s', "'" + model + "'") # TODO!!! escape properly
      cursor = connect().cursor()
      cursor.execute(sql)