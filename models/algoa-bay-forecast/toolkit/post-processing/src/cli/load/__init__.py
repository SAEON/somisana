import os
from re import sub
from numpy import var
import xarray as xr
from datetime import datetime
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME
from postgis import connect as connectPg

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
    print('\n-> Loading dataset', dataset, str(datetime.now() - now))
    p, filename =  os.path.split("""{0}:{1}""".format(str(nc_input_path), str(dataset)))

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
        -t 19x53 \
        -F \
        -s 4326 \
        NETCDF:"{1}":{2} \
        public.{3} \
        | psql \
          postgres://{4}:{5}@{6}:{7}/{8}""".format(
            str(mode),
            str(nc_input_path),
            str(dataset),
            str(table),
            str(PG_USERNAME),
            str(PG_PASSWORD),
            str(PG_HOST),
            str(PG_PORT),
            str(PG_DB)
          )
        
    print("""\nCommand:""".format(str(dataset)), sub(' +', ' ', cmd))
    if os.system(cmd) != 0:
      raise Exception('raster2pgsql cmd failed: ' + sub(' +', ' ', cmd))
  
  print('\nNetCDF data registered as out-db successfully!!', str(datetime.now() - now))

