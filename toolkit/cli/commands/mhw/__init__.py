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
        "--clear-cache",
        action="store_true",
        default=False,
        help="Re-download data used for calculating thresholds",
    )
    mhw_start.add_argument(
        "--skip-caching-oisst",
        action="store_true",
        default=False,
        help="Skip checking for new OISST entries",
    )
    mhw_start.add_argument(
        "--nc-thresholds-path",
        default=".thresholds.nc",
        help="Path to SST Thresholds NetCDF file",
    )
    mhw_start.add_argument(
        "--nc-mhw-output-path",
        default=".marine-heat-waves.nc",
        help="Path to SST Marine Heat Waves events NetCDF file",
    )
    mhw_start.add_argument(
        "--mhw-bulk-cache",
        required=False,
        help="Path to directory containing back data (AVHRR OISST data from NOAA) used to calculate thresholds NetCDF file",
    )
    mhw_start.add_argument(
        "--thresholds-expiry",
        type=int,
        choices=range(-1, 9999),
        metavar="",
        default=100,
        help="Maximum age in days of thresholds, before requireing new thresholds be calculated (0, always expire the thresholds file. -1 == never expire the thresholds file)",
    )
    mhw_start.add_argument(
        '--chown',
        type=str,
        required=False,
        help='Run "chown" system call on downloaded/created files with the provided user:group (i.e. "runner:runners"")'
    )
    mhw_start.add_argument(
        "--domain",
        help="Bounding box in 4326 projection (i.e. min_long,max_long,min_lat,max_lat)",
        required=True
    )

    return mhw
