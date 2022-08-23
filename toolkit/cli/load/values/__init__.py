from postgis import connect
from datetime import datetime
from time import sleep

MAX_RETRIES = 5


def upsert(model, run_date, now):
    # Resolve the modelid from the name
    cursor = connect().cursor()
    cursor.execute("""select id from models where name = %s""", (model,))
    modelid = cursor.fetchall()[0][0]

    # Upsert for every depth at every time step
    for time_step in range(240):
        for depth_level in range(20):
            d = depth_level + 1
            t = time_step + 1
            attempt = 1
            successful = False
            while not successful and attempt <= MAX_RETRIES:
                try:
                    print('--> Refreshing values at depth level',
                          f'{d:02}', 'timestep', f'{t:03}', str(datetime.now() - now))
                    cursor = connect().cursor()
                    cursor.execute("""
                      select upsert_values (modelid => %s, rundate => %s,  depth_level => %s, time_step => %s)""", (modelid, run_date, d, t))
                    successful = True
                except:
                    print('--> ERROR on attempt', attempt, 'of', MAX_RETRIES)
                    attempt += 1
                    sleep(10)
