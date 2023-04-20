from cli.applications.ops.load.values.load_band import load
from config import PG_DB, PG_PORT, PG_HOST, PG_PASSWORD, PG_USERNAME
from multiprocessing import cpu_count
import asyncio
import asyncpg

cpus = cpu_count()

total_timesteps = 240


async def load_worker(queue, async_pool, runid, datetimes, total_depth_levels):
    while True:
        item = await queue.get()
        if item is None:
            break
        depth_level, i = item
        await load(i, depth_level, runid, datetimes, total_depth_levels, async_pool)
        queue.task_done()


async def upsert(runid, depths, datetimes, total_depth_levels, parallelization):
    start_depth, end_depth = depths.split(",")
    depth_levels = [*range(int(start_depth), int(end_depth) + 1, 1)]
    async_pool = await asyncpg.create_pool(
        database=PG_DB,
        host=PG_HOST,
        password=PG_PASSWORD,
        port=PG_PORT,
        user=PG_USERNAME,
        min_size=cpus,
        max_size=cpus * 4,
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
