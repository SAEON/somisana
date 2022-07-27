import os
from datetime import timedelta, date
from pathlib import Path
from config import COPERNICUS_PASSWORD, COPERNICUS_USERNAME, DOWNLOADS_DIRECTORY
from cli.download.sources.gfs import gfs
from cli.download.sources.mercator import mercator

DOWNLOADS_PATH = os.path.join(DOWNLOADS_DIRECTORY, 'forcing-inputs/')
MATLAB_ENV_PATH = os.path.join(DOWNLOADS_DIRECTORY, '.env')

def download(options, arguments):
  print('Downloading forecast model boundary data...')

  hdays = 5 
  fdays = 5
  date_now = date.today() # use datetime() as we use 00:00:00 as the reference time
  date_start = date_now + timedelta(days=-hdays)
  date_end = date_now + timedelta(days=fdays)
  domain = [22, 31, -37, -31] # Extent (4326)
  varsOfInterest = ['so', 'thetao', 'zos', 'uo', 'vo'] # Mercator
  depths = [0.493, 5727.918] # Mercator [min, max]

  print('date', str(date_now))
  print('hindcast days', str(hdays))
  print('forecast days', str(fdays))
  print('simulation temporal coverage', str(date_start), '-', str(date_end))
  print('spatial extent for download of global forcing data (west, east, south, north)', str(domain))

  print('Downloads path (creating if it doesn\'t exist', DOWNLOADS_PATH)
  Path(DOWNLOADS_PATH).mkdir(parents=True, exist_ok=True)

  # Download GFS data (ocean surface weather data)
  print('Downloading GFS data...')
  delta_days_gfs = gfs(date_now, hdays, fdays, domain, DOWNLOADS_PATH)

    # Download Mercator data (ocean boundary data)
  print('Downloading Mercator data...')
  mercator(
      COPERNICUS_USERNAME,
      COPERNICUS_PASSWORD,
      domain,
      date_now,
      hdays,
      fdays,
      varsOfInterest,
      depths,
      DOWNLOADS_PATH
  )

  # MatLab is configured via a .env file
  print('Configuring MatLab...')
  with open(MATLAB_ENV_PATH, 'w+') as env:
      env.write("""RUN_DATE={0}
  DELTA_DAYS_GFS={1}
  """
      .format(
          str(date.today()),
          str(delta_days_gfs)
      ))
  os.chmod(MATLAB_ENV_PATH, 0o777)

  # Script complete
  print('Complete!')