import xarray as xr
import asyncio
import os
import json
import asyncpg
from config import PG_DB, PG_PORT, PG_HOST, PG_PASSWORD, PG_USERNAME
from lib.log import log
from lib.open_files import open_files
from datetime import datetime
from cli.applications.croco.load_pp_v1_output_to_pg.upsert_model_info import (
    upsert_model_info,
)
from cli.applications.croco.load_pp_v1_output_to_pg.upsert_model_run import (
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
    log("Loading post-processed CROCO output (v1) to PostgreSQL")
    input = os.path.abspath(args.input)
    parallelization = args.parallelization
    log("CONFIG::input", input)
    log("CONFIG::parallelization", parallelization)

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
            run_date = ds.attrs["run_date"]
            log("Model:", id, "run_date", run_date)

            # Get the model configuration
            model = [model for model in json.load(models_f) if model.get("id") == id]
            model = model[0] if model and len(model) > 0 else None
            if model == None:
                log(
                    f'Model id: "{id}" is not defined in the models.json configuration file - this needs to be specified manually'
                )
                exit()

            # Upsert model information
            await upsert_model_info(
                pool=pool,
                id=id,
                model=model,
                merge_details=merge_details_f.read(),
                merge_coordinates=merge_coordinates_f.read(),
                update_geospatial_fields=update_geospatial_fields_f.read(),
            )

            # Upsert model run
            await upsert_model_run(
                pool=pool,
                id=id,
                run_date=run_date,
                ds=ds,
                input=input,
                model=model,
                parallelization=parallelization,
            )


def load_pp_v1_output_to_pg(args):
    asyncio.run(run(args))
