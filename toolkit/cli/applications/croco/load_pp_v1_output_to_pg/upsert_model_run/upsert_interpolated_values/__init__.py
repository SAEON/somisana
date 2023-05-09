from cli.applications.croco.load_pp_v1_output_to_pg.upsert_model_run.upsert_interpolated_values.load_band import (
    load,
)
from config import PG_DB, PG_PORT, PG_HOST, PG_PASSWORD, PG_USERNAME
import asyncio
import asyncpg


async def load_worker(queue, async_pool, runid):
    while True:
        item = await queue.get()
        if item is None:
            break
        depth, i = item
        await load(i, depth, runid, async_pool)
        queue.task_done()


async def upsert_interpolated_values(
    runid, interpolated_depths, parallelization, total_timesteps
):
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
        asyncio.create_task(load_worker(queue, async_pool, runid))
        for _ in range(parallelization)
    ]

    for depth in interpolated_depths:
        for i in range(total_timesteps):
            await queue.put((depth, i))

    await queue.join()

    for _ in worker_tasks:
        await queue.put(None)

    await asyncio.gather(*worker_tasks)
    await async_pool.close()
