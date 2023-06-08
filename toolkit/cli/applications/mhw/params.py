import os
from config import CACHDIR
from os.path import join

OISST_CACHE = join(CACHDIR, "ohw", "thresholds", "bulk")
OISST_DATA = "https://www.ncei.noaa.gov/thredds/catalog/OisstBase/NetCDF/V2.1/AVHRR"

# Ensure cache directory exists
os.makedirs(OISST_CACHE, exist_ok=True)
