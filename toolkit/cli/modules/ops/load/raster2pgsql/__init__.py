import os
import json
from re import sub
import xarray as xr
import numpy as np
from postgis import pool
from datetime import datetime
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME, PY_ENV


def register(config, now, nc_input_path, raster, model, reload_data, runid):
    print("\n->", raster, str(datetime.now() - now))
    p, filename = os.path.split("""{0}:{1}""".format(str(nc_input_path), str(raster)))

    if not config[model]:
        raise Exception("No configuration for model", model)
    if not config[model][raster]:
        raise Exception("No configuration for model", model, "variable", raster)

    # raster2pgsql -t auto value defaults to the grid size (156x106) which
    # is too large for in-db rasters. This seems to work with out-db rasters,
    # but regardless it's probably more performant to work with smaller tile
    # sizes. However, the tile sizes then need to be set explicitly for each
    # variable
    tileDimensions = config[model][raster]["tile_size"]
    if not tileDimensions:
        raise Exception(
            "Tile dimensions not specified for",
            raster,
            "Please update this in the source code manually above",
        )

    # In development it's nice to skip this
    # but in production, if boundary data
    # changes then the the output would change
    # so rasters should be reloaded
    if not reload_data:
        if not PY_ENV == "development":
            raise Exception(
                "In production mode, raster data should ALWAYS re-inserted to the DB since the GFC initialization data is likely to be different for re-runs"
            )
        else:
            with pool().connection() as client:
                cursor = client.execute(
                    """select 1 where exists ( select * from public.rasters where filename = %s )""",
                    (filename,),
                )
                exists = not len(cursor.fetchall()) == 0

                if exists:
                    print("skipping (raster already exists in DB)")
                    return

    # In case this function is re-run from the same input file, first delete
    # previous input from that file (otherwise there will be duplicate raster).
    # So far as I'm aware there is no way to check uniqueness of rasters loaded
    # via raster2pgsql. This query should never fail as the table should be created
    # as part of the DDL specification (schema.sql)
    with pool().connection() as client:
        client.cursor().execute(
            """delete from public.rasters where filename = %s""",
            (filename,),
        )

    # Load rasters into the DB. In the future it may be useful to have
    # out-db rasters, so the flag is left here as a stub. Note that the
    # srid is set to 0 (-s 0) as the grid is not geobound, but instead
    # integer based.
    out_db_flag = ""
    cmd = """
    raster2pgsql \
      -a \
      -q \
      -t {0} \
      -F \
      -s 0 \
      {1} \
      NETCDF:"{2}":{3} \
      public.rasters \
      | psql \
        postgres://{4}:{5}@{6}:{7}/{8}""".format(
        str(tileDimensions),
        str(out_db_flag),
        str(nc_input_path),
        str(raster),
        str(PG_USERNAME),
        str(PG_PASSWORD),
        str(PG_HOST),
        str(PG_PORT),
        str(PG_DB),
    )

    print("""Command:""".format(str(raster)), sub(" +", " ", cmd))
    if os.system(cmd) != 0:
        raise Exception("raster2pgsql cmd failed: " + sub(" +", " ", cmd))

    # Explicitly associate individual rasters with a run
    with open("cli/modules/ops/load/raster2pgsql/update-raster_xref_run.sql") as file:
        sql = file.read()
        with pool().connection(timeout=3600) as client:
            cursor = client.execute(
                sql,
                (
                    filename,
                    runid,
                ),
            )

    # Register raster metadata in the run table
    # This is configured per raster
    with pool().connection() as client:
        with xr.open_dataset(nc_input_path) as ds:
            match raster:
                case "time":
                    attrs = ds[raster].attrs
                    initial_time = ds[raster][0].values
                    timestamp = np.datetime_as_string(initial_time, unit="s")
                    client.cursor().execute(
                        """
                        merge into public.runs t
                        using (
                            select
                                %s runid,
                                %s step1_timestamp,
                                %s timestep_attrs
                        ) s on s.runid = t.id
                        when matched then
                            update set
                                step1_timestamp = s.step1_timestamp::timestamp,
                                timestep_attrs = s.timestep_attrs::json;
                        """,
                        (runid, timestamp, json.dumps(attrs)),
                    )
