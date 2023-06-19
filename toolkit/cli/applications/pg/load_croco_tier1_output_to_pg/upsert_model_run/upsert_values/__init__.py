from cli.applications.pg.load_croco_tier1_output_to_pg.upsert_model_run.upsert_values.load_band import (
    load,
)
from config import PG_DB, PG_PORT, PG_HOST, PG_PASSWORD, PG_USERNAME
import asyncio
import asyncpg


async def load_worker(queue, async_pool, runid, datetimes, total_depth_levels):
    while True:
        item = await queue.get()
        if item is None:
            break
        depth_level, i = item
        await load(i, depth_level, runid, datetimes, total_depth_levels, async_pool)
        queue.task_done()


async def upsert_values(
    runid, datetimes, total_depth_levels, parallelization, total_timesteps
):
    depth_levels = [*range(int(1), int(total_depth_levels) + 1, 1)]
    async_pool = await asyncpg.create_pool(
        database=PG_DB,
        host=PG_HOST,
        password=PG_PASSWORD,
        port=PG_PORT,
        user=PG_USERNAME,
        min_size=4,
        max_size=32,
    )
    queue = asyncio.Queue()
    worker_tasks = [
        asyncio.create_task(
            load_worker(queue, async_pool, runid, datetimes, total_depth_levels)
        )
        for _ in range(parallelization)
    ]

    for depth_level in depth_levels:
        for i in range(total_timesteps):
            await queue.put((depth_level, i))

    await queue.join()

    for _ in worker_tasks:
        await queue.put(None)

    await asyncio.gather(*worker_tasks)
    await async_pool.close()
