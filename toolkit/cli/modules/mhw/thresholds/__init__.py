import os
from asyncio import run
from os.path import join
from config import CACHDIR
from lib import fetch
from siphon.catalog import TDSCatalog
from cli.modules.mhw.thresholds.catalogue import find_downloads, download_files
from cli.modules.mhw.thresholds.climatolgy import calculate_daily_clim

MHW_BULK_CACHE = join(CACHDIR, "ohw", "thresholds", "bulk")
OISST_DATA = "https://www.ncei.noaa.gov/thredds/catalog/OisstBase/NetCDF/V2.1/AVHRR"

# Ensure cache directory exists
os.makedirs(MHW_BULK_CACHE, exist_ok=True)


def create_thresholds(args):
    nc_thresholds_path = os.path.abspath(args.nc_thresholds_path)
    domain = [float(x) for x in args.domain.split(",")]
    reset_cache = args.reset_cache
    mhw_bulk_cache = (
        os.path.abspath(args.mhw_bulk_cache) if args.mhw_bulk_cache else MHW_BULK_CACHE
    )
    print("Searching ncie.noaa catalogues")
    # catalog = TDSCatalog("{url}/catalog.xml".format(url=OISST_DATA))
    # refs = catalog.catalog_refs
    # files = run(find_downloads(refs, OISST_DATA))
    # run(download_files(files, domain, mhw_bulk_cache, reset_cache))
    # download_files(files, domain, mhw_bulk_cache, reset_cache)
    calculate_daily_clim(domain, mhw_bulk_cache, nc_thresholds_path)
    exit()

    # Download the back SST data
    # Then figure out the logic of updating the cache

    # Download new SST data
    # Generate new thresholds file
