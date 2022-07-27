import xarray as xr
from datetime import datetime
from cli.load.postgis import __ini__
from cli.load.postgis.coordinates import create_view as index_coordinates
from cli.load.postgis.raster2pgsql import register as raster2pgsql
from cli.load.postgis.metadata import setup as register_metadata_view


def load(options, arguments):
  print('\n== Running Algoa Bay Forecast post-processing ==')
  
  # Parse CLI options
  nc_input_path = options.nc_input_path

  # For logging times
  now = datetime.now()
  print('\n-> Installing PostGIS schema', str(datetime.now() - now))

  # Get a list of the raster paths in the NetCDF file
  netcdf = xr.open_dataset(nc_input_path)
  variables = list(netcdf.keys())
  coords = list(netcdf.coords)
  rasters = list(set(variables + coords))
  rasters.sort()

  # Load rasters into PostGIS - one at a time
  print('\n-> Loading variables', rasters, str(datetime.now() - now))
  # for raster in rasters:
  #   raster2pgsql(now, nc_input_path, raster)
  
  # All rasters loaded!
  print('\nNetCDF data registered as out-db successfully!!', str(datetime.now() - now))

  # Coordinates should never change. Load them if they don't exist
  print('\n-> Calculating coordinates', str(datetime.now() - now))
  index_coordinates()

  # If the models view doesn't already exist create it
  print('\n-> Setting up models view', str(datetime.now() - now))
  register_metadata_view()

