import os
from os.path import join
from config import CACHDIR
from cli.applications.mhw.thresholds.catalogue import update_cache
from oisst import Catalogue

MHW_BULK_CACHE = join(CACHDIR, "ohw", "thresholds", "bulk")
OISST_DATA = "https://www.ncei.noaa.gov/thredds/catalog/OisstBase/NetCDF/V2.1/AVHRR"

# Ensure cache directory exists
os.makedirs(MHW_BULK_CACHE, exist_ok=True)


def update_catalogue(args):
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
