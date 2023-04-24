import os
import json
import numpy as np
from lib.log import log
from re import sub
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME


async def upsert_rasters(conn, runid, raster, input, model, ds):
    p, filename = os.path.split("""{0}:{1}""".format(str(input), str(raster)))

    tileDimensions = model["postgis_config"][raster]["tile_size"]
    if not tileDimensions:
        raise Exception(
            "Tile dimensions not specified for",
            raster,
            "Please update this in the source code manually above",
        )

    # In case this function is re-run from the same input file, first delete
    # previous input from that file (otherwise there will be duplicate raster).
    # So far as I'm aware there is no way to check uniqueness of rasters loaded
    # via raster2pgsql
    q1 = await conn.prepare("delete from public.rasters where filename = $1")
    await q1.fetch(filename)

    # Load rasters into the DB. In the future it may be useful to have
    # out-db rasters, so the flag is left here as a stub. Note that the
    # srid is set to 0 (-s 0) as the grid is not geobound, but instead
    # integer based.
    out_db_flag = ""
    cmd = f"""
    raster2pgsql \
      -a \
      -q \
      -t {str(tileDimensions)} \
      -F \
      -s 0 \
      {str(out_db_flag)} \
      NETCDF:"{str(input)}":{str(raster)} \
      public.rasters \
      | psql \
        postgres://{str(PG_USERNAME)}:{str(PG_PASSWORD)}@{str(PG_HOST)}:{str(PG_PORT)}/{str(PG_DB)}"""

    log(" ".join(cmd.split()))

    # Execute the PostGIS CLI
    if os.system(cmd) != 0:
        raise Exception("raster2pgsql cmd failed: " + sub(" +", " ", cmd))

    # Explicitly associate individual rasters with a run
    q2 = await conn.prepare(
        """
        ;with ref as (
        select
            $1::text filename,
            $2::smallint runid
        )
        insert into raster_xref_run(rasterid, runid)
        select
            r.rid rasterid,
            ref.runid
        from ref
        join rasters r on r.filename = ref.filename
        where not exists (
            select 1
            from
            raster_xref_run x
            where
            x.rasterid = r.rid
            and x.runid = ref.runid);"""
    )
    await q2.fetch(filename, runid)

    # Register raster metadata in the run table
    # This is configured per raster
    match raster:
        case "time":
            attrs = ds[raster].attrs
            initial_time = ds[raster][0].values
            timestamp = np.datetime_as_string(initial_time, unit="s")
            q3 = await conn.prepare(
                """
                merge into public.runs t
                using (
                    select
                        $1::smallint runid,
                        $2 step1_timestamp,
                        $3 timestep_attrs
                ) s on s.runid = t.id
                when matched then
                    update set
                        step1_timestamp = s.step1_timestamp::timestamp,
                        timestep_attrs = s.timestep_attrs::json;
                """
            )
            await q3.fetch(runid, timestamp, json.dumps(attrs))

    log(f"Completed importing {filename}!")
