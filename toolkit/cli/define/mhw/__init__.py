def build(module_parser):
    mhw = module_parser.add_parser("mhw", help="Marine Heat Waves (MHW) module")
    mhw_parser = mhw.add_subparsers(
        title="Marine Heat Waves (MHW)",
        description="Look for high normal variance of SST compared to the previous decades",
        dest="mhw_command",
        metavar="Available commands",
    )

    # update-catalogue
    mhw_update_catalogue = mhw_parser.add_parser(
        "update-catalogue", help="Update daily OISST product cache in local environment"
    )
    mhw_update_catalogue.add_argument(
        "--chown",
        type=str,
        required=False,
        help='Run "chown" system call on downloaded/created files with the provided user:group (i.e. "runner:runners"")',
    )
    mhw_update_catalogue.add_argument(
        "--domain",
        help="Bounding box in 4326 projection (i.e. west,east,south,north)",
        required=True,
    )
    mhw_update_catalogue.add_argument(
        "--clear-cache",
        action="store_true",
        default=False,
        help="Re-download data used for calculating thresholds",
    )
    mhw_update_catalogue.add_argument(
        "--skip-caching-oisst",
        action="store_true",
        default=False,
        help="Skip checking for new OISST entries",
    )
    mhw_update_catalogue.add_argument(
        "--oisst-cache",
        required=False,
        help="Path to directory containing back data (AVHRR OISST data from NOAA) used to calculate thresholds NetCDF file",
    )

    # detect
    mhw_detect = mhw_parser.add_parser(
        "detect",
        help="Run the ecjoliver/marineHeatWaves script on the OISST daily cache to detect MHW events",
    )
    mhw_detect.add_argument(
        "--output", default=".output.nc", help="Path of NetCDF output path"
    )
    mhw_detect.add_argument(
        "--domain",
        help="Bounding box in 4326 projection (i.e. west,east,south,north)",
        required=True,
    )
    mhw_detect.add_argument(
        "--oisst-cache",
        required=False,
        help="Path to directory containing back data (AVHRR OISST data from NOAA) used to calculate thresholds NetCDF file",
    )

    return mhw
