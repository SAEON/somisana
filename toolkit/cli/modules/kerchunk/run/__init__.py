from kerchunk import hdf
from kerchunk.combine import MultiZarrToZarr
import fsspec
import os


def run(args):
    inputs = [args.inputs]
    output = os.path.abspath(args.output)
    replace_uri = args.replace_uri
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

    if replace_uri:
        print(replace_uri)
        old_val, new_val = replace_uri.split(",")
        with open(output, "r") as f:
            file_contents = f.read()
        modified_contents = file_contents.replace(
            old_val,
            new_val,
        )
        with open(output, "w") as f:
            f.write(modified_contents)
