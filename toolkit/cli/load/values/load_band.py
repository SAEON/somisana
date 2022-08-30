from postgis import pool
from datetime import datetime
from time import sleep
from pandas import Timestamp

MAX_RETRIES = 10


def load(modelid, depth_level, run_date, start_time, datetimes):
    for i in range(240):
        time_step = i + 1
        timestamp = Timestamp(datetimes[i]).to_pydatetime()
        attempt = 1
        successful = False
        while not successful and attempt <= MAX_RETRIES:
            try:
                print(
                    str(datetime.now() - start_time).split(".")[0],
                    "::",
                    "Refreshing values at depth level",
                    f"{depth_level:02}",
                    "timestep",
                    f"{time_step:03}",
                    "(" + str(timestamp) + ")",
                    "run_date",
                    run_date,
                )
                with pool().connection() as client:
                    client.execute(
                        query="""select upsert_values (modelid => %s, rundate => %s,  depth_level => %s, time_step => %s, actual_time => %s)""",
                        params=(
                            modelid,
                            run_date,
                            depth_level,
                            time_step,
                            timestamp,
                        ),
                        prepare=False,
                    )
                    successful = True
                    if attempt > 1:
                        print(
                            "--> Succeeded on attempt",
                            attempt,
                            "depth level",
                            depth_level,
                            "time step",
                            i,
                        )
            except Exception as e:
                print(
                    "--> ERROR on attempt",
                    attempt,
                    "of",
                    MAX_RETRIES,
                    e,
                    "depth level",
                    depth_level,
                    "time step",
                    time_step,
                )
                attempt += 1
                sleep(10)

        if attempt > MAX_RETRIES:
            raise Exception("upsert_values function failed to many times")
