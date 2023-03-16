from datetime import datetime, timedelta
import os
from config import COPERNICUS_PASSWORD, COPERNICUS_USERNAME
import xarray as xr


def is_valid_netcdf_file(file_path):
    try:
        with xr.open_dataset(file_path) as ds:
            return True
    except:
        return False


"""
Download latest daily ocean forecasts from CMEMS GLOBAL-ANALYSIS-FORECAST-PHY-001-024
Dependencies: (see https://marine.copernicus.eu/faq/what-are-the-motu-and-python-requirements/)
python -m pip install motuclient
Adapted script from Mostafa Bakhoday-Paskyabi <Mostafa.Bakhoday@nersc.no>
"""

# so = Salinity in psu
# thetao = Temperature in degrees C
# zos = SSH in m,
# uo = Eastward velocity in m/s
# vo = Northward velocity in m/s
VARIABLES = ["so", "thetao", "zos", "uo", "vo"]
DEPTH_RANGE = [0.493, 5727.918]


def download(run_date, hdays, fdays, domain, workdir):
    hdays = hdays + 1
    fdays = fdays + 1
    startDate = run_date + timedelta(days=-hdays)
    endDate = run_date + timedelta(days=fdays)

    var_str = ""
    for var in VARIABLES:
        var_str = var_str + " --variable " + var

    fname = "mercator_" + str(run_date.strftime("%Y%m%d")) + ".nc"

    runcommand = (
        "motuclient --quiet"
        + " --user "
        + COPERNICUS_USERNAME
        + " --pwd "
        + COPERNICUS_PASSWORD
        + " --motu http://nrt.cmems-du.eu/motu-web/Motu"
        + " --service-id GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS"
        + " --product-id global-analysis-forecast-phy-001-024"
        + " --longitude-min "
        + str(domain[0])
        + " --longitude-max "
        + str(domain[1])
        + " --latitude-min "
        + str(domain[2])
        + " --latitude-max "
        + str(domain[3])
        + ' --date-min "'
        + str(startDate.strftime("%Y-%m-%d"))
        + '" --date-max "'
        + str(endDate.strftime("%Y-%m-%d"))
        + '"'
        + " --depth-min "
        + str(DEPTH_RANGE[0])
        + " --depth-max "
        + str(DEPTH_RANGE[1])
        + var_str
        + " --out-dir "
        + os.path.normpath(workdir)
        + " --out-name "
        + fname
    )

    f = os.path.normpath(os.path.join(workdir, fname))
    if os.path.exists(f) == False:
        print("downloading latest mercator ocean forecast from CMEMS...")
        startTime = datetime.now()
        if os.system(runcommand) != 0:
            raise Exception("Mercator download failed from cmd: " + runcommand)
        else:
            if is_valid_netcdf_file(f):
                print("mercator download completed", str(datetime.now() - startTime))
            else:
                raise Exception("Mercator download failed (bad NetCDF output)")
    else:
        print(
            os.path.normpath(os.path.join(workdir, fname)),
            "already exists - not downloading mercator data",
        )
