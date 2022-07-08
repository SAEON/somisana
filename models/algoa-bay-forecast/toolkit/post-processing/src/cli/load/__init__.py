import os
from re import sub
from numpy import var
import xarray as xr
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME
from postgis import connection as pgConnection

def load(options, arguments):
  nc_input_path = options.nc_input_path

  netcdf = xr.open_dataset(nc_input_path)
  variables = list(netcdf.keys())
  print(variables)
  print(netcdf)
  exit()
  
  for i, variable in enumerate(variables):
    p, filename =  os.path.split("""{0}:{1}""".format(str(nc_input_path), str(variable)))

    # Delete the entry for this raster (to make the function idempotent)
    mode = '-a'
    try:
      pgConnection.cursor().execute("delete from public.algoa_bay_forecast where filename = %s", (filename, ))
    except:
      mode = '-d'

    # Register this raster
    cmd = """
      raster2pgsql \
        {0} \
        -q \
        -I \
        -t auto \
        -R \
        -F \
        -s 4326 \
        NETCDF:"{1}":{2} \
        public.algoa_bay_forecast \
        | psql \
          postgres://{3}:{4}@{5}:{6}/{7}""".format(
            str(mode),
            str(nc_input_path),
            str(variable),
            str(PG_USERNAME),
            str(PG_PASSWORD),
            str(PG_HOST),
            str(PG_PORT),
            str(PG_DB)
          )
        
    print("""\nLoading variable {0}:""".format(str(variable)), sub(' +', ' ', cmd))
    os.system(cmd)

  print('\nNetCDF data registered as out-db successfully!!')

