import xarray as xr
import asyncio
import os
import json
import asyncpg
from config import PG_DB, PG_PORT, PG_HOST, PG_PASSWORD, PG_USERNAME
from lib.log import log
from datetime import datetime
from lib.open_files import open_files
from cli.applications.pg.load_croco_tier1_output_to_pg.upsert_model_info import (
    upsert_model_info,
)
from cli.applications.pg.load_croco_tier1_output_to_pg.upsert_rasters import (
    upsert_rasters,
)
from cli.applications.pg.load_croco_tier1_output_to_pg.upsert_model_run import (
    upsert_model_run,
)

models_file = os.path.abspath("models.json")

current_dir = os.path.dirname(os.path.abspath(__file__))
merge_details_file = os.path.join(current_dir, "upsert_model_info/upsert-details.sql")
merge_coordinates_file = os.path.join(
    current_dir, "upsert_model_info/upsert-coordinates.sql"
)
update_geospatial_fields_file = os.path.join(
    current_dir, "upsert_model_info/update-geospatial-fields.sql"
)


async def run(args):
    log("Loading tier1 regridded CROCO output to PostgreSQL")

    input = os.path.abspath(args.input)
    parallelization = args.parallelization
    log("CONFIG::input", input)
    log("CONFIG::parallelization", parallelization)
    log("CONFIG::DB::host", PG_HOST)
    log("CONFIG::DB::port", PG_PORT)
    log("CONFIG::DB::database", PG_DB)

    pool = await asyncpg.create_pool(
        database=PG_DB,
        host=PG_HOST,
        password=PG_PASSWORD,
        port=PG_PORT,
        user=PG_USERNAME,
        min_size=4,
        max_size=32,
    )

    # Open SQL and configuration files
    with open_files(
        models_file,
        merge_details_file,
        merge_coordinates_file,
        update_geospatial_fields_file,
    ) as fds:
        (
            models_f,
            merge_details_f,
            merge_coordinates_f,
            update_geospatial_fields_f,
        ) = fds

        # Open the input dataset
        with xr.open_dataset(input) as ds:
            id = ds.attrs["model_name"]
            run_date = datetime.strptime(ds.attrs["run_date"], "%Y%m%d").date()
            log(f"Model: {id}. Run date: {run_date}")

            # Get the model configuration
            model = [model for model in json.load(models_f) if model.get("id") == id]
            model = model[0] if model and len(model) > 0 else None
            if model == None:
                log(
                    f'Model id: "{id}" is not defined in the models.json configuration file - this needs to be specified manually'
                )
                exit()

            # Upsert into public.runs
            log("Starting transaction")
            async with pool.acquire() as conn:
                async with conn.transaction():
                    q1 = await conn.prepare(
                        """
                        merge into public.runs t
                        using (
                            select
                                $1::date run_date,
                                ( select id from models where name = $2 ) modelid
                        ) s on
                            s.run_date = t.run_date
                            and s.modelid = t.modelid
                        when
                            not matched then
                                insert (run_date, modelid)
                                values (s.run_date, s.modelid);
                        """
                    )
                    log(f" => {q1}")
                    await q1.fetch(run_date, id)

                    # Get the run ID
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
                    log(f" => {q2}")
                    r = await q2.fetch(run_date, id)
                    runid = r[0]["id"]
                    log(f"  => Run ID {runid} cached")
                

                # Upsert rasters
                variables = list(ds.keys())
                coords = list(ds.coords)
                rasters = list(set(variables + coords))
                rasters.sort()
                for raster in rasters:
                    if model["postgis_config"].get(raster) is not None:
                        await upsert_rasters(conn, runid, raster, input, model, ds)
                    else:
                        log(
                            f"No PostGIS configuration found for raster {raster} (defined in models.yml). Skipping raster load"
                        )

                    # Upsert model information
                    await upsert_model_info(
                        conn=conn,
                        id=id,
                        model=model,
                        merge_details=merge_details_f.read(),
                        merge_coordinates=merge_coordinates_f.read(),
                        update_geospatial_fields=update_geospatial_fields_f.read(),
                    )
                log("Transaction complete")

            # Upsert model run
            # This can't be in a single transaction as it is split across many connections for parallelization
            await upsert_model_run(
                runid=runid,
                pool=pool,
                ds=ds,
                parallelization=parallelization,
            )


def load_croco_tier1_output_to_pg(args):
    asyncio.run(run(args))
