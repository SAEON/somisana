from kerchunk import hdf
from kerchunk.combine import MultiZarrToZarr
import fsspec
import os


def run(args):
    inputs = [args.inputs]
    output = os.path.abspath(args.output)
    singles = []
    for input in inputs:
        with fsspec.open(input) as inf:
            h5chunks = hdf.SingleHdf5ToZarr(inf, input, inline_threshold=100)
            chunk = h5chunks.translate()
            singles.append(chunk)

    mzz = MultiZarrToZarr(
        singles,
        remote_protocol="http",
        remote_options={"anon": True},
        concat_dims=["time"],
    )
    mzz.translate(output)
