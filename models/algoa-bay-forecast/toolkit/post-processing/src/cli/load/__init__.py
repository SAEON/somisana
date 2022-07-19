import os
from re import sub
from numpy import var
import xarray as xr
from datetime import datetime
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME
from postgis import connect as connectPg

t = {
  "temperature": "38x53",
  "salt": "38x53",
  "v": "38x53",
  "u": "38x53",
  "m_rho": "38x53",
  "lon_rho": "38x53",
  "lat_rho": "38x53",
  "time": "240x1",
  "depth": "20x1"
}

def load(options, arguments):
  print('\n== Running Algoa Bay Forecast post-processing ==')
  now = datetime.now()
  nc_input_path = options.nc_input_path
  table = 'algoa_bay_forecast'

  netcdf = xr.open_dataset(nc_input_path)
  variables = list(netcdf.keys())
  coords = list(netcdf.coords)
  data = list(set(variables + coords))
  data.sort()
  print('\n-> Loading variables', data, str(datetime.now() - now))

  for dataset in data:
    print('\n->', dataset, str(datetime.now() - now))
    p, filename =  os.path.split("""{0}:{1}""".format(str(nc_input_path), str(dataset)))
    
    # raster2pgsql -t auto value defaults to the grid size (156x106)
    # This is too large for in-db rasters. Not sure about out-db
    # rasters
    tileDimensions = t[dataset]
    if not tileDimensions:
      raise Exception('Tile dimensions not specified for', dataset, 'Please update this in the source code manually above')

    # Delete the entry for this raster (to make the function idempotent)
    mode = '-a'
    try:
      connectPg().cursor().execute("""delete from public.{0} where filename = %s""".format(table), (filename, ))
    except:
      mode = '-d'

    # Register this raster as an in-db raster
    # Add back -R flag for out-db raster
    cmd = """
      raster2pgsql \
        {0} \
        -q \
        -I \
        -t {1} \
        -F \
        -s 4326 \
        NETCDF:"{2}":{3} \
        public.{4} \
        | psql \
          postgres://{5}:{6}@{7}:{8}/{9}""".format(
            str(mode),
            str(tileDimensions),
            str(nc_input_path),
            str(dataset),
            str(table),
            str(PG_USERNAME),
            str(PG_PASSWORD),
            str(PG_HOST),
            str(PG_PORT),
            str(PG_DB)
          )
        
    print("""Command:""".format(str(dataset)), sub(' +', ' ', cmd))
    if os.system(cmd) != 0:
      raise Exception('raster2pgsql cmd failed: ' + sub(' +', ' ', cmd))
  
  print('\nNetCDF data registered as out-db successfully!!', str(datetime.now() - now))

