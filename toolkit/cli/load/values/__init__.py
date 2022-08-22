from postgis import connect
from datetime import datetime

def upsert(model, run_date, now):
  # Resolve the modelid from the name
  cursor = connect().cursor()
  cursor.execute("""select id from models where name = %s""", (model,))
  modelid = cursor.fetchall()[0][0]
  
  # Upsert for every depth at every time step
  for time_step in range(240):
    for depth_level in range(20):
      print('--> Refreshing values at depth level', depth_level + 1, 'timestep', time_step + 1, str(datetime.now() - now))
      cursor = connect().cursor()
      cursor.execute("""
        select upsert_values (modelid => %s, rundate => %s,  depth_level => %s, time_step => %s)""", (modelid, run_date, depth_level + 1, time_step + 1))