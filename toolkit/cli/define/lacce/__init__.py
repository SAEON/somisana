def build(module_parser):
    lacce = module_parser.add_parser("lacce", help="LACCE module")
    lacce.add_argument("--input", help="Path to input NetCDF file")
    lacce.add_argument("--output", help="Path to output NetCDF file")
    return lacce