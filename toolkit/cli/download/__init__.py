import os
from datetime import datetime, timedelta, date
from pathlib import Path
from config import COPERNICUS_PASSWORD, COPERNICUS_USERNAME
from cli.download.sources.gfs import gfs
from cli.download.sources.mercator import mercator

def download(options, arguments):
  print('Downloading forecast model boundary data...')

  workdir = options.workdir
  matlab_env = options.matlab_env
  run_date = datetime.strptime(options.download_date, '%Y%m%d')
  domain = list(map(lambda i: float(i), options.domain.split(',')))
  
  hdays = 5 
  fdays = 5
  date_start = run_date + timedelta(days=-hdays)
  date_end = run_date + timedelta(days=fdays)
  varsOfInterest = ['so', 'thetao', 'zos', 'uo', 'vo'] # Mercator
  depths = [0.493, 5727.918] # Mercator [min, max]

  print('date', str(run_date))
  print('hindcast days', str(hdays))
  print('forecast days', str(fdays))
  print('simulation temporal coverage', str(date_start), '-', str(date_end))
  print('spatial extent for download of global forcing data (west, east, south, north)', str(domain))

  print('Downloads path', workdir)
  Path(workdir).mkdir(parents=True, exist_ok=True)

  # Download GFS data (ocean surface weather data)
  print('Downloading GFS data...')
  delta_days_gfs = gfs(run_date, hdays, fdays, domain, workdir)

    # Download Mercator data (ocean boundary data)
  print('Downloading Mercator data...')
  mercator(
      COPERNICUS_USERNAME,
      COPERNICUS_PASSWORD,
      domain,
      run_date,
      hdays,
      fdays,
      varsOfInterest,
      depths,
      workdir
  )

  # MatLab is configured via a .env file
  print('Configuring MatLab...')
  with open(matlab_env, 'w+') as env:
    env.writelines([
      'RUN_DATE=' + str(date.today()) + '\n',
      'DELTA_DAYS_GFS=' + str(delta_days_gfs) + '\n'
    ])
  os.chmod(matlab_env, 0o777)

  # Script complete
  print('Complete!')