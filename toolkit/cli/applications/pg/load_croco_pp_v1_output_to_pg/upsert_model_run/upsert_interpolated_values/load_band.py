from time import sleep
from config import PY_ENV
from lib.log import log

MAX_RETRIES = 1 if PY_ENV == "development" else 5


async def load(i, depth, runid, async_pool):
    time_step = i + 1
    attempt = 1
    successful = False
    while not successful and attempt <= MAX_RETRIES:
        try:
            async with async_pool.acquire() as conn:
                await conn.fetch(
                    f"""
                    merge into public.interpolated_values_runid_{runid} t
                    using (
                        select
                            v.coordinateid,
                            {time_step} time_step,
                            {depth} depth,
                            {runid} runid,
                            v.long x,
                            v.lat y,
                            v.interpolated_temperature::float temperature,
                            v.interpolated_salinity::float salinity,
                            v.interpolated_u::float u,
                            v.interpolated_v::float v,
                            st_x (c.pixel) px,
                            st_y (c.pixel) py
                        from
                            somisana_interpolate_values(
                                target_depth => {depth},
                                runid => {runid},
                                time_step => {time_step}
                            ) v
                        inner join public.coordinates c on c.id = v.coordinateid
                    ) s on 
                        s.coordinateid = t.coordinateid
                        and s.time_step = t.time_step
                        and s.depth = t.depth
                        and s.runid = t.runid
                    when
                        not matched then
                            insert
                                (coordinateid, time_step, depth, runid, x, y, temperature, salinity, u, v, px, py)
                            values
                                (s.coordinateid, s.time_step, s.depth, s.runid, s.x, s.y, s.temperature, s.salinity, s.u, s.v, s.px, s.py)
                        when matched then
                            update
                                set
                                    x = s.x,
                                    y = s.y,
                                    temperature = s.temperature,
                                    salinity = s.salinity,
                                    u = s.u,
                                    v = s.v,
                                    px = s.px,
                                    py = s.py;
                    """
                )

                successful = True
                log(
                    f"Loaded interpolated band: depth={depth:02} timestep={time_step:03} runid {runid}"
                )
                if attempt > 1:
                    log(
                        "--> Succeeded on attempt",
                        attempt,
                        "depth",
                        depth,
                        "time step",
                        time_step,
                    )
        except Exception as e:
            log(
                "--> ERROR on attempt",
                attempt,
                "of",
                MAX_RETRIES,
                e,
                "depth",
                depth,
                "time step",
                time_step,
            )
            attempt += 1
            sleep(1)

    if attempt > MAX_RETRIES:
        raise Exception("upsert_interpolated_values function failed too many times")
