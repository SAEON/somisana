import xarray as xr
import yaml
from datetime import datetime
from postgis import setup as installDb, drop as dropSchema, pool
from config import PY_ENV
from cli.load.raster2pgsql import register as raster2pgsql
from cli.load.coordinates import upsert as upsert_coordinates
from cli.load.values import upsert as upsert_values

def load(options, arguments):
    now = datetime.now()
    model_name = options.model_name
    model_data = options.model_data
    run_date = options.run_date
    drop_db = options.drop_db
    reload_data = options.reload_data
    run_date = options.run_date

    """
    Check CLI options are specified correctly
    """
    if not model_name:
        raise Exception("Please specify the model name (-m)")
    if not model_data:
        raise Exception("Please specify the file input name (-i)")

    """
    Check that the correct run_date is specified
    The default is today, but if a bad format is
    passed that must be raised
    """
    try:
        datetime.strptime(run_date, "%Y%m%d")
    except:
        raise Exception("Expected date format for --run-date is %Y%m%d")

    """
    In development mode when the schema changes a lot, it's
    useful to be able to drop and recreate the schema
    """
    if drop_db:
        if not PY_ENV == "development":
            raise Exception(
                'Dropping database schema is only supported when PY_ENV == "development"'
            )
        else:
            dropSchema()

    """
    On every run the DB schema DDL is run. This won't change the schema
    object if they already exist - changes to the schema won't automatically
    reflect
    """
    installDb()

    """
    This script loads database for a number of different models. These
    models are defined in the schema.sql file. Users must explicitly say
    which model the data is for - relying on file name format is not a good
    idea
    """
    with pool.connection() as client:
        cursor = client.execute(
            """select 1 where exists (select * from models where "name" = %s)""",
            (model_name,),
        )
        model_exists = len(cursor.fetchall())

    if not model_exists:
        raise Exception("Specified model does not exist exist - " + model_name)
    else:
        print("""\n== Loading PostGIS data ({0} model) ==""".format(model_name))
        print("\n-> Installing PostGIS schema", str(datetime.now() - now))

    config = None
    with open("cli/load/models.yml") as file:
        config = yaml.load(file, yaml.Loader)["models"]

    """
    The NetCDF file has many rasters - each variable/coordinate
    is a raster. Each raster has to be loaded into the DB individually.
    Try "gdalinfo /path/to/file.nc" to see a list of the 'subdatasets'.
    Each subdataset is a raster. Unlike gdalinfo, Xarray splits subdatasets
    into keys (variables) and coords (also variables in this context) 
    """
    netcdf = xr.open_dataset(model_data)
    variables = list(netcdf.keys())
    coords = list(netcdf.coords)
    rasters = list(set(variables + coords))
    rasters.sort()
    
    print("\n-> Loading variables", rasters, str(datetime.now() - now))
    for raster in rasters: raster2pgsql(config, now, model_data, raster, model_name, reload_data, run_date)
    print("\nNetCDF data loaded successfully!!", str(datetime.now() - now))

    """
    Coordinates are stored in the DB as EPSG:4326. Each model is done
    on a fixed XY grid - so the coordinates don't change.
    """
    print("\n-> Calculating and loading coordinates", str(datetime.now() - now))
    upsert_coordinates(model_name)

    # If the models view doesn't already exist create it
    print("\n-> Calculating and loading data values", str(datetime.now() - now))
    upsert_values(model_name, run_date, now, config)
