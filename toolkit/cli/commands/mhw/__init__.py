def build(module_parser):
    mhw = module_parser.add_parser("mhw", help="Marine Heat Waves (MHW) module")
    mhw_parser = mhw.add_subparsers(
        title="Marine Heat Waves (MHW)",
        description="Look for high normal variance of SST compared to the previous decades",
        dest="mhw_command",
        metavar="Available commands",
    )

    # Start
    mhw_start = mhw_parser.add_parser(
        "start", help="Track marine heat waves from daily data"
    )
    mhw_start.add_argument(
        "--nc-output-path", default=".output.nc", help="Path of NetCDF output path"
    )
    mhw_start.add_argument(
        "--nc-thresholds-path",
        default=".thresholds.nc",
        help="Path to SST Thresholds NetCDF file",
    )
    mhw_start.add_argument(
        "--nc-thresholds-src-dir",
        default=".thresholds-src",
        help="Path to directory containing back data (AVHRR OISST data from NOAA)",
    )
    mhw_start.add_argument(
        "--thresholds-expiry",
        type=int,
        choices=range(-1, 9999),
        default=100,
        help="Maximum age in days of thresholds, before requireing new thresholds be calculated (0, always expire the thresholds file. -1 == never expire the thresholds file)",
    )

    return mhw
