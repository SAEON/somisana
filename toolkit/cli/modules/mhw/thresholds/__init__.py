import os
from os.path import join
from config import CACHDIR
from lib import fetch

MHW_BULK_CACHE = join(CACHDIR, "ohw", "thresholds", "bulk")
os.makedirs(MHW_BULK_CACHE, exist_ok=True)

def create_thresholds(args):
    nc_thresholds_path = os.path.abspath(args.nc_thresholds_path)
    mhw_bulk_cache = (
        os.path.abspath(args.mhw_bulk_cache) if args.mhw_bulk_cache else MHW_BULK_CACHE
    )
    print("Implementing", mhw_bulk_cache)
    exit()

    # Download the back SST data
    # Then figure out the logic of updating the cache

    # Download new SST data
    # Generate new thresholds file
