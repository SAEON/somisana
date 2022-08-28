import xarray as xr
import yaml
from datetime import datetime
from postgis import setup as installDb, drop as dropSchema, pool
from config import PY_ENV
from cli.load.raster2pgsql import register as refresh_rasters
from cli.load.coordinates import upsert as refresh_coordinates
from cli.load.values import upsert as refresh_values


def load(options, arguments):
    start_time = datetime.now()
    model_config = None

    model = options.model
    model_data = options.model_data
    run_date = options.run_date
    drop_db = options.drop_db
    reload_data = options.reload_data
    run_date = options.run_date
    upsert_rasters = options.upsert_rasters
    upsert_coordinates = options.upsert_coordinates
    upsert_values = options.upsert_values
    depths = options.depths
    install_db = options.install_db

    if not upsert_rasters and not upsert_coordinates and not upsert_values:
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
            print(str(datetime.now() - start_time).split('.')[0], "::", "Installing PostGIS schema")

    with open("cli/load/models.yml") as file:
        model_config = yaml.load(file, yaml.Loader)["models"]

    if upsert_rasters:
        netcdf = xr.open_dataset(model_data)
        variables = list(netcdf.keys())
        coords = list(netcdf.coords)
        rasters = list(set(variables + coords))
        rasters.sort()
        for raster in rasters:
            refresh_rasters(
                model_config, start_time, model_data, raster, model, reload_data, run_date
            )

    if upsert_coordinates:
        refresh_coordinates(model, start_time)

    if upsert_values:
        refresh_values(model, run_date, start_time, depths)
