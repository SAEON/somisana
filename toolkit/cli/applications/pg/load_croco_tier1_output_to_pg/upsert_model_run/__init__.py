from lib.log import log
from cli.applications.pg.load_croco_tier1_output_to_pg.upsert_model_run.upsert_values import (
    upsert_values,
)
from cli.applications.pg.load_croco_tier1_output_to_pg.upsert_model_run.upsert_interpolated_values import (
    upsert_interpolated_values,
)


async def update_values_schema(conn, *cmds):
    for cmd in cmds:
        log(f" => {cmd}")
        await conn.fetch(cmd)


async def upsert_model_run(runid, pool, ds, parallelization):

    async with pool.acquire() as conn:
        log("Starting transaction")
        async with conn.transaction():
            # Register new partition and indexes
            await update_values_schema(
                conn,
                # values partition
                f"drop table if exists public.values_runid_{runid};",
                f"create table if not exists public.values_runid_{runid} partition of public.values for values in ({runid});",
                f"create index if not exists values_cols_{runid} on public.values_runid_{runid} using btree(time_step asc, depth_level desc);",
                f"create index if not exists values_coordinateid_{runid} on public.values_runid_{runid} using btree(coordinateid asc);",
                # interpolated_values partition
                f"drop table if exists public.interpolated_values_runid_{runid};",
                f"create table if not exists public.interpolated_values_runid_{runid} partition of public.interpolated_values for values in ({runid});",
                f"create index if not exists interpolated_values_cols_band_{runid} on public.interpolated_values_runid_{runid} using btree(time_step asc, depth desc);",
                f"create index if not exists interpolated_values_coordinateid_{runid} on public.interpolated_values_runid_{runid} using btree(coordinateid asc);",
            )
        log("Transaction complete")

    datetimes = ds.time.values
    total_depth_levels = ds.sizes["s_rho"]
    total_timesteps = ds.sizes["time"]
    log("Total s_rho levels", total_depth_levels)
    log("Total timesteps", total_timesteps)

    # Upsert values
    await upsert_values(
        runid, datetimes, total_depth_levels, parallelization, total_timesteps
    )

    # Upsert interpolated values
    interpolated_depths = [
        -5,
        -10,
        -15,
        -20,
        -30,
        -40,
        -50,
        -60,
        -70,
        -100,
        -200,
        -500,
        -1000,
        -2000,
    ]
    await upsert_interpolated_values(
        runid, interpolated_depths, parallelization, total_timesteps
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
                            coordinateid = c.id
                    )
            )
            update public.coordinates c
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
        log("Re-analysed tables")
