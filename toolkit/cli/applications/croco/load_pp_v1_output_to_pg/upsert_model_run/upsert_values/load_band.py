from time import sleep
from config import PY_ENV
from lib.log import log
from pandas import Timestamp

MAX_RETRIES = 1 if PY_ENV == "development" else 5


async def load(i, depth_level, runid, datetimes, total_depth_levels, async_pool):
    time_step = i + 1
    timestamp = Timestamp(datetimes[i]).to_pydatetime()
    attempt = 1
    successful = False
    while not successful and attempt <= MAX_RETRIES:
        try:
            async with async_pool.acquire() as conn:
                stmt = await conn.prepare(
                    "SELECT somisana_upsert_values(run_id => $1, depth_level => $2, time_step => $3, total_depth_levels => $4)"
                )
                await stmt.fetch(runid, depth_level, time_step, total_depth_levels)
                successful = True
                log(
                    f"Loaded band: depth={depth_level:02} timestep={(i+1):03} runid {runid}. timestep {timestamp}"
                )
                if attempt > 1:
                    log(
                        "--> Succeeded on attempt",
                        attempt,
                        "depth level",
                        depth_level,
                        "time step",
                        i,
                    )
        except Exception as e:
            log(
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
            sleep(1)

    if attempt > MAX_RETRIES:
        raise Exception("upsert_values function failed to many times")
