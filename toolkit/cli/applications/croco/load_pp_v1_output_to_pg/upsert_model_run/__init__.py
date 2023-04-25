from lib.log import log
from datetime import datetime
from cli.applications.croco.load_pp_v1_output_to_pg.upsert_model_run.upsert_rasters import (
    upsert_rasters,
)
from cli.applications.croco.load_pp_v1_output_to_pg.upsert_model_run.upsert_values import (
    upsert_values,
)


async def upsert_model_run(pool, id, run_date, ds, input, model, parallelization):
    run_date = datetime.strptime(run_date, "%Y%m%d").date()
    runid = None

    async with pool.acquire() as conn:
        # Register the run
        async with conn.transaction():
            q1 = await conn.prepare(
                """
                merge into public.runs t
                using (
                select
                    $1::date run_date, (
                    select
                        id
                    from
                        models
                    where
                        name = $2) modelid) s on s.run_date = t.run_date
                    and s.modelid = t.modelid
                when not matched then
                    insert (run_date, modelid)
                    values (s.run_date, s.modelid);
                """
            )
            await q1.fetch(run_date, id)
            q2 = await conn.prepare(
                """
                select
                    r.id
                from
                    runs r
                join
                    models m on m.id = r.modelid 
                where
                    r.run_date = $1
                    and m.name = $2
                """
            )
            r = await q2.fetch(run_date, id)
            runid = r[0]["id"]
            log("=> Run ID", runid)

        # Register new partition and indexes
        async with conn.transaction():
            await conn.fetch(
                f"create table if not exists public.values_runid_{runid} partition of public.values for values in ({runid});"
            )
            await conn.fetch(
                f"create unique index if not exists values_unique_cols_{runid} on public.values_runid_{runid} using btree(runid desc, time_step asc, depth_level desc, coordinateid);"
            )
            await conn.fetch(
                f"create index if not exists values_coordinateid_{runid} on public.values_runid_{runid} using btree(coordinateid asc);"
            )
            await conn.fetch(
                f"create index if not exists values_runs_{runid} on public.values_runid_{runid} using btree(runid desc);"
            )

    # Upsert rasters
    variables = list(ds.keys())
    coords = list(ds.coords)
    rasters = list(set(variables + coords))
    rasters.sort()
    async with pool.acquire() as conn:
        for raster in rasters:
            await upsert_rasters(conn, runid, raster, input, model, ds)

    # Upsert values
    datetimes = ds.time.values
    total_depth_levels = ds.sizes["depth"]
    total_timesteps = ds.sizes["time"]
    log("Total depth levels", total_depth_levels)
    log("Total timesteps", total_timesteps)
    await upsert_values(
        runid, datetimes, total_depth_levels, parallelization, total_timesteps
    )

    # Finalize the run
    async with pool.acquire() as conn:
        # Update coordinate sea/land mask
        await conn.fetch(
            f"""
            with _coordinates as (
            select distinct
                c.id
            from
                public.coordinates c
            where
                c.has_value = false
                and exists (
                select
                    1
                from
                public.values_runid_{runid}
                where
                    coordinateid = c.id)
            )
            update
            public.coordinates c
            set
            has_value = true
            where
            c.id in (
                select
                    id
                from
                    _coordinates);
            """
        )
        log("Updated coordinate mask")

        # Delete rasters
        q3 = await conn.prepare(
            """
            delete from public.rasters r
            where rid in (
                select
                    x.rasterid
                from
                    raster_xref_run x
                where
                    x.runid = $1);
            """
        )
        await q3.fetch(runid)
        log("Removed rasters")

        # Tag run as successful
        q4 = await conn.prepare(
            "update public.runs set successful = true where id = $1;"
        )
        await q4.fetch(runid)
        log(f"Marked run {runid} as successful")

        # Analyze tables
        await conn.fetch(f"analyze public.runs;")
        await conn.fetch(f"analyze public.rasters;")
        await conn.fetch(f"analyze public.values_runid_{runid};")
        log("Re-analyzed tables")
