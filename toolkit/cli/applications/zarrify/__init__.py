import xarray as xr
from lib.log import log
import os

chunk_sizes = {"time": 24, "depth": 1, "latitude": -1, "longitude": -1}


def zarrify(args):
    input = os.path.abspath(args.input)
    output = os.path.abspath(args.output)
    log(f"Zarrifying {input} to {output}")

    ds = xr.open_dataset(input, chunks=chunk_sizes)

    ds.to_zarr(output, mode="w", consolidated=True)
    log(f"Complete!")
