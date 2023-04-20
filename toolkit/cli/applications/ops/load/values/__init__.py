from lib.log import log
from cli.applications.ops.load.values.load_band import load
from config import PG_DB, PG_PORT, PG_HOST, PG_PASSWORD, PG_USERNAME
import asyncio
import asyncpg


async def upsert(runid, depths, datetimes, total_depth_levels):
    start_depth, end_depth = depths.split(",")
    depth_levels = [*range(int(start_depth), int(end_depth) + 1, 1)]
    async_pool = await asyncpg.create_pool(
        database=PG_DB,
        host=PG_HOST,
        password=PG_PASSWORD,
        port=PG_PORT,
        user=PG_USERNAME,
        min_size=1,
        max_size=10,
    )
    tasks = []
    for depth_level in depth_levels:
        for i in range(240):
            log(f"Loading band: depth={depth_level} timestep={i+1}")
            tasks.append(
                asyncio.create_task(
                    load(
                        i,
                        depth_level,
                        runid,
                        datetimes,
                        total_depth_levels,
                        async_pool,
                    )
                )
            )
    await asyncio.gather(*tasks)
    await async_pool.close()
