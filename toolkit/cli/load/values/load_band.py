from postgis import pool
from datetime import datetime
from time import sleep

MAX_RETRIES = 5


def load(depth_level, run_date, start_time, modelid):
    for time_step in range(240):
        t = time_step + 1
        attempt = 1
        successful = False
        while not successful and attempt <= MAX_RETRIES:
            try:
                print(
                    "--> Refreshing values at depth level",
                    f"{depth_level:02}",
                    "timestep",
                    f"{t:03}",
                    str(datetime.now() - start_time),
                )
                with pool.connection() as client:
                    cursor = client.cursor()
                    cursor.execute(
                        """select upsert_values (modelid => %s, rundate => %s,  depth_level => %s, time_step => %s)""",
                        (modelid, run_date, depth_level, t),
                    )
                    successful = True
            except Exception as e:
                print("--> ERROR on attempt", attempt, "of", MAX_RETRIES, e)
                attempt += 1
                sleep(10)
