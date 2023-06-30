import os
from cli.applications.mhw.update_catalogue.update_cache import update_cache
from oisst import Catalogue
import glob
from cli.applications.mhw.params import OISST_CACHE, OISST_DATA


def update_catalogue(args):
    chown = args.chown
    domain = [float(x) for x in args.domain.split(",")]
    skip_caching_oisst = args.skip_caching_oisst
    clear_cache = args.clear_cache
    oisst_cache = os.path.abspath(args.oisst_cache) if args.oisst_cache else OISST_CACHE

    # Update the OISST cache
    if skip_caching_oisst:
        print("Skipping caching OISST backdata (--skip-caching-oisst)")
    else:
        with Catalogue("{url}/catalog.xml".format(url=OISST_DATA)) as catalogue:
            refs = catalogue.catalog_refs
            update_cache(refs, OISST_DATA, domain, oisst_cache, clear_cache, chown)
            print("OISST cache updated!")
