def build(module_parser):
    mhw = module_parser.add_parser("mhw", help="Marine Heat Waves (MHW) module")
    mhw_parser = mhw.add_subparsers(
        title="Marine Heat Waves (MHW)",
        description="Look for high normal variance of SST compared to the previous decades",
        dest="mhw_command",
        metavar="Available commands",
    )

    # Download
    mhw_download = mhw_parser.add_parser("download", help="Download NOAA data")
    mhw_download.add_argument("-d", "--date-range", help="Date range")
    mhw_download.add_argument(
        "--nc-output-path", default=".output.nc", help="Path of NetCDF output path"
    )
    
    # Thresholds
    mhw_thresholds = mhw_parser.add_parser(
        "thresholds", help="Determine thresholds from downloaded NetCDF file"
    )
    mhw_thresholds.add_argument("-i", "--input-path", help="Input data")
    
    # Detect
    mhw_detect = mhw_parser.add_parser("detect", help="Detect heat-wave events")
    mhw_detect.add_argument(
        "-i", "--input-path", help="Operational data input (NetCDF file)"
    )
    mhw_detect.add_argument(
        "-t", "--thresholds-input-path", help="Threshold data input (NetCDF file)"
    )
    return mhw
