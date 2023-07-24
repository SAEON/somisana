def build(module_parser):
    zarrify = module_parser.add_parser("zarrify", help="ZARRIFY module")
    zarrify.add_argument("--input", help="Path to input NetCDF file")
    zarrify.add_argument("--output", help="Path to output Zarr directory")
    return zarrify