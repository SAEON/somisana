import os
from os.path import join
from lib import CACHDIR

OHW_BULK_CACHE = join(CACHDIR, 'ohw', 'thresholds', 'bulk')
os.makedirs(OHW_BULK_CACHE, exist_ok=True)



def create_thresholds(args):
    nc_thresholds_path = os.path.abspath(args.nc_thresholds_path)
    nc_thresholds_src_dir = os.path.abspath(args.nc_thresholds_src_dir)
    print('Implementing')
    exit()
    
    # Download new SST data
    # Generate new thresholds file
    
