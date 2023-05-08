import asyncio
import asyncpg
from lib.log import log
from config import PG_DB, PG_PORT, PG_HOST, PG_PASSWORD, PG_USERNAME


async def run():
    async with asyncpg.create_pool(
        database=PG_DB,
        host=PG_HOST,
        password=PG_PASSWORD,
        port=PG_PORT,
        user=PG_USERNAME,
        min_size=1,
        max_size=1,
    ) as pool:
        async with pool.acquire() as conn:
            async with conn.transaction():
                rows = await conn.fetch(
                    """
                    with recent_successful_runs as (
                    select 
                        id, 
                        modelid, 
                        row_number() over (
                        partition by modelid 
                        order by 
                            id desc
                        ) as row_num 
                    from 
                        public.runs 
                    where 
                        successful = true
                    ), 
                    delete_from as (
                    select 
                        modelid, 
                        max(id) runid 
                    from 
                        recent_successful_runs 
                    where 
                        row_num > 5
                    group by 
                        modelid 
                    having 
                        max(id) > min(id)
                    ) 
                    select 
                    r.modelid, 
                    id runid 
                    from 
                    public.runs r 
                    join delete_from d on d.modelid = r.modelid 
                    and r.id <= d.runid

                    """
                )
                if len(rows) < 1:
                    log("No runs found to delete")
                else:
                    for row in rows:
                        modelid = row["modelid"]
                        runid = row["runid"]
                        log(f"Deleting run {runid} (model ID {modelid})")
                        await conn.execute(f"drop table public.values_runid_{runid};")
                        await conn.execute(
                            f"delete from public.runs where id = {runid}"
                        )


def prune_values(args):
    log("Pruning old model runs from values partitions")
    asyncio.run(run())
