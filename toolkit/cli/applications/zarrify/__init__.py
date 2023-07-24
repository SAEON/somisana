import xarray as xr
from lib.log import log
import os

def zarrify(args):
  input = os.path.abspath(args.input)
  output = os.path.abspath(args.output)
  log(f"Zarrifying {input} to {output}")
  
  ds = xr.open_dataset(input, chunks={})
  ds.to_zarr(output, mode='w')
  log(f"Complete!")