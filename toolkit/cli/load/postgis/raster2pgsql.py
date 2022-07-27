import os
from re import sub
from postgis import connect as connectPg
from datetime import datetime
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME

TABLE = 'rasters'

"""
Source grid
152x106
"""
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

def register(now, nc_input_path, raster, model):
  print('\n->', raster, str(datetime.now() - now))
  p, filename =  os.path.split("""{0}:{1}""".format(str(nc_input_path), str(raster)))
  
  # raster2pgsql -t auto value defaults to the grid size (156x106)
  # This is too large for in-db rasters. Not sure about out-db
  # rasters
  tileDimensions = t[raster]
  if not tileDimensions:
    raise Exception('Tile dimensions not specified for', raster, 'Please update this in the source code manually above')

  # Delete the entry for this raster (to make the function idempotent)
  mode = '-a'
  try:
    connectPg().cursor().execute("""delete from public.{0} where filename = %s""".format(TABLE), (filename, ))
  except:
    mode = '-d'

  # out-db rasters - currently can't configure but might be useful for dev
  out_db_flag = ''

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
      {2} \
      NETCDF:"{3}":{4} \
      public.{5} \
      | psql \
        postgres://{6}:{7}@{8}:{9}/{10}""".format(
          str(mode),
          str(tileDimensions),
          str(out_db_flag),
          str(nc_input_path),
          str(raster),
          str(TABLE),
          str(PG_USERNAME),
          str(PG_PASSWORD),
          str(PG_HOST),
          str(PG_PORT),
          str(PG_DB)
        )
      
  print("""Command:""".format(str(raster)), sub(' +', ' ', cmd))
  # if os.system(cmd) != 0:
  #   raise Exception('raster2pgsql cmd failed: ' + sub(' +', ' ', cmd))

  # TODO associate filename with the mode
  