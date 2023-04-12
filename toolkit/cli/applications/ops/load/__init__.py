import xarray as xr
import yaml
from datetime import datetime
from postgis import setup as installDb, drop as dropSchema, pool
from config import PY_ENV
from cli.applications.ops.load.raster2pgsql import register as refresh_rasters
from cli.applications.ops.load.coordinates import upsert as refresh_coordinates
from cli.applications.ops.load.values import upsert as refresh_values
from cli.applications.ops.load.finalize import run as finalize


def load(args):
    start_time = datetime.now()
    model_config = None

    model = args.model
    model_data = args.model_data
    run_date = args.run_date
    drop_db = args.drop_db
    reload_data = args.reload_data
    upsert_rasters = args.upsert_rasters
    upsert_coordinates = args.upsert_coordinates
    upsert_values = args.upsert_values
    depths = args.depths
    install_db = args.install_db
    finalize_run = args.finalize_run

    if (
        not upsert_rasters
        and not upsert_coordinates
        and not upsert_values
        and not finalize_run
    ):
        print("No upsert options specified! Nothing to do (please read the help)")
        exit(0)

    if drop_db:
        if not PY_ENV == "development":
            raise Exception(
                'Dropping database schema is only supported when PY_ENV == "development"'
            )
        else:
            dropSchema()
            installDb()

    if not model:
        raise Exception("Please specify the model name")

    if install_db:
        installDb()

    if upsert_rasters:
        if not model_data:
            raise Exception("Please specify the file input name")

    if upsert_values:
        if not depths:
            raise Exception("Please specify depth range for this script")
        if not model_data:
            raise Exception("Please specify the file input name")

    try:
        datetime.strptime(run_date, "%Y%m%d")
    except:
        raise Exception("Expected date format for --run-date is %Y%m%d")

    # Check the specified model exists
    with pool().connection() as client:
        cursor = client.execute(
            """select 1 where exists (select * from models where "name" = %s)""",
            (model,),
        )
        if not len(cursor.fetchall()):
            raise Exception("Specified model does not exist exist - " + model)
        else:
            print("""\n== Loading PostGIS data ({0} model) ==""".format(model))
            print(
                str(datetime.now() - start_time).split(".")[0],
                "::",
                "Installing PostGIS schema",
            )

    # Register this run_date
    # TODO the merge code is run on the load at the moment,
    # which means runid.successful is getting toggled when it shouldn't be
    runid = None
    with pool().connection() as client:
        client.execute(
            """
            merge into public.runs t
            using (
            select
                %s::date run_date, (
                select
                    id
                from
                    models
                where
                    name = %s) modelid) s on s.run_date = t.run_date
                and s.modelid = t.modelid
            when not matched then
                insert (run_date, modelid)
                values (s.run_date, s.modelid);
            """,
            (
                run_date,
                model,
            ),
        )
        runid = client.execute(
            """
            select
                r.id
            from
                runs r
            join
                models m on m.id = r.modelid 
            where
                r.run_date = %s
                and m.name = %s""",
            (run_date, model),
        ).fetchall()[0][0]

    with open("cli/modules/ops/load/models.yml") as file:
        model_config = yaml.load(file, yaml.Loader)["models"]

    if upsert_rasters:
        rasters = None
        with xr.open_dataset(model_data) as netcdf:
            variables = list(netcdf.keys())
            coords = list(netcdf.coords)
            rasters = list(set(variables + coords))
        rasters.sort()
        for raster in rasters:
            refresh_rasters(
                model_config,
                start_time,
                model_data,
                raster,
                model,
                reload_data,
                runid,
            )

    if upsert_coordinates:
        refresh_coordinates(model, start_time)

    if upsert_values:
        datetimes = None
        total_depth_levels = None
        with xr.open_dataset(model_data) as netcdf:
            # TODO The metadata contains the datetime step information
            # This should be in the model table, and datetimes worked out from there
            datetimes = netcdf.time.values
            total_depth_levels = netcdf.sizes["depth"]
        refresh_values(runid, start_time, depths, datetimes, total_depth_levels)

    if finalize_run:
        finalize(start_time, model, runid)
