def build(module_parser):
    kerchunk = module_parser.add_parser("kerchunk", help="Kerchunk module")
    kerchunk_parser = kerchunk.add_subparsers(
        title="Kerchunk",
        description="Publish NetCDF and other other spatial data in cloud-optimised formats",
        dest="kerchunk_command",
        metavar="Available commands",
    )

    kerchunk_run = kerchunk_parser.add_parser("run", help="Run the Kerchunk CLI")
    kerchunk_run.add_argument(
        "--inputs", default=".output.nc", help="Path to input NetCDF files"
    )
    kerchunk_run.add_argument(
        "--output",
        default=".output/kerchunk.json",
        help="Path to output file",
    )
    return kerchunk
