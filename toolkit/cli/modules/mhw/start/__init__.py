import os
import requests
from datetime import date
import datetime

# (1) Check if thresholds file exists, if it doesn't (or is older than 1 month)
#  => download back data
#  => generate thresholds data
#
# (2) Download today's SST
# (3) Run the tracker function to produce the output NetCDF file
# (4) Make that available to web -> PostGIS? JSON? NetCDF?


def start(args):
    nc_output_path = args.nc_output_path

    # Account for latency of the SST product
    today = date.today()
    yesterday = today - datetime.timedelta(days=2)
    n_day = yesterday.strftime("%d")
    long_day = yesterday.strftime("%j")
    n_month = yesterday.strftime("%m")
    n_year = yesterday.strftime("%Y")
    n_hour = "120000"

    url = "{base_url}{n_year}/{long_day}/{n_year}{n_month}{n_day}{n_hour}-NCEI-L4_GHRSST-SSTblend-AVHRR_OI-GLOB-v02.0-fv02.1.nc".format(
        base_url="https://opendap.jpl.nasa.gov/opendap/hyrax/OceanTemperature/ghrsst/data/GDS2/L4/GLOB/NCEI/AVHRR_OI/v2.1/",
        n_year=str(n_year),
        long_day=str(long_day),
        n_month=str(n_month),
        n_day=str(n_day),
        n_hour=str(n_hour),
    )
    print('Downloading', url, 'to', os.path.abspath(nc_output_path))

    progress = 0
    with requests.get(url, stream=True) as response:
        with open(nc_output_path, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                progress = progress + len(chunk)
                msg = "Downloaded {progress}MB".format(
                    progress=str(round(progress / 1000 / 1000, 2))
                )
                print(msg)
                f.write(chunk)

    print('Complete!')
