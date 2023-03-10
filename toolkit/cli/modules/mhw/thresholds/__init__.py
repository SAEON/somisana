import os
from os.path import join
from config import CACHDIR
from cli.modules.mhw.thresholds.catalogue import update_cache
from cli.modules.mhw.thresholds.climatology import calculate_daily_clim
from cli.modules.mhw.thresholds.climatology import calculate_mhw
from oisst import Catalogue

MHW_BULK_CACHE = join(CACHDIR, "ohw", "thresholds", "bulk")
OISST_DATA = "https://www.ncei.noaa.gov/thredds/catalog/OisstBase/NetCDF/V2.1/AVHRR"

# Ensure cache directory exists
os.makedirs(MHW_BULK_CACHE, exist_ok=True)


def create_thresholds(args):
    nc_thresholds_path = os.path.abspath(args.nc_thresholds_path)
    nc_mhw_output_path = os.path.abspath(args.nc_mhw_output_path)
    chown = args.chown
    domain = [float(x) for x in args.domain.split(",")]
    skip_caching_oisst = args.skip_caching_oisst
    clear_cache = args.clear_cache
    mhw_bulk_cache = (
        os.path.abspath(args.mhw_bulk_cache) if args.mhw_bulk_cache else MHW_BULK_CACHE
    )

    # Update the OISST cache
    if skip_caching_oisst:
        print("Skipping caching OISST backdata (--skip-caching-oisst)")
    else:
        with Catalogue("{url}/catalog.xml".format(url=OISST_DATA)) as catalogue:
            refs = catalogue.catalog_refs
            update_cache(refs, OISST_DATA, domain, mhw_bulk_cache, clear_cache, chown)
            print("OISST cache updated!")

    # Create thresholds from OISST cache
    calculate_daily_clim(mhw_bulk_cache, nc_thresholds_path, domain)

    # Create mhw output classifications of cached data? or part of cache data?
    calculate_mhw(mhw_bulk_cache, nc_thresholds_path, nc_mhw_output_path)
    print(
        """Marine Heat Wave events saved to {filename}""".format(
            filename=args.nc_mhw_output_path
        )
    )
