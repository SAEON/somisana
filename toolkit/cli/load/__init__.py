import xarray as xr
from datetime import datetime
from postgis import setup as installDb, drop as dropSchema, connect
from config import PY_ENV
from cli.load.raster2pgsql import register as raster2pgsql
from cli.load.coordinates import merge as index_coordinates
from cli.load.values import merge as index_values


def load(options, arguments):
  now = datetime.now()
  model = options.model
  nc_input_path = options.nc_input_path
  run_date = options.run_date
  drop_db = options.drop_db
  reload_existing_data = options.reload_existing_data
  
  """
  Check CLI options are specified correctly
  """
  if not model: raise Exception('Please specify the model name (-m)')
  if not nc_input_path: raise Exception('Please specify the file input name (-i)')

  """
  Check that the correct run_date is specified
  The default is today, but if a bad format is
  passed that must be raised
  """
  try:
    datetime.strptime(run_date, '%Y%m%d')
  except:
    raise Exception("Expected date format for --run-date is %Y%m%d")

  """
  In development mode when the schema changes a lot, it's
  useful to be able to drop and recreate the schema
  """
  if drop_db:
    if not PY_ENV == 'development':
      raise Exception('Dropping database schema is only supported when PY_ENV == "development"')
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
  cursor = connect().cursor()
  cursor.execute("""select 1 where exists (select * from models where "name" = %s)""", (model, ))
  model_exists = len(cursor.fetchall())
  if not model_exists:
    raise Exception('Specified model does not exist exist - ' + model)
  else:
    print("""\n== Loading PostGIS data ({0} model) ==""".format(model))
    print('\n-> Installing PostGIS schema', str(datetime.now() - now))

  """
  The NetCDF file has many rasters - each variable/coordinate
  is a raster. Each raster has to be loaded into the DB individually.
  Try "gdalinfo /path/to/file.nc" to see a list of the 'subdatasets'.
  Each subdataset is a raster. Unlike gdalinfo, Xarray splits subdatasets
  into keys (variables) and coords (also variables in this context) 
  """
  netcdf = xr.open_dataset(nc_input_path)
  variables = list(netcdf.keys())
  coords = list(netcdf.coords)
  rasters = list(set(variables + coords))
  rasters.sort()
  print('\n-> Loading variables', rasters, str(datetime.now() - now))
  for raster in rasters: raster2pgsql(now, nc_input_path, raster, model, reload_existing_data)
  print('\nNetCDF data loaded successfully!!', str(datetime.now() - now))

  """
  Coordinates are stored in the DB as EPSG:4326. Each model is done
  on a fixed XY grid - so the coordinates don't change.
  """
  print('\n-> Calculating and loading coordinates', str(datetime.now() - now))
  index_coordinates(model)

  # If the models view doesn't already exist create it
  print('\n-> Calculating and loading data values', str(datetime.now() - now))
  index_values(model, run_date)

