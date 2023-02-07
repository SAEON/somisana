import argparse
from datetime import datetime
from cli.ops import download as opsDownload, transform as opsTransform, load as opsLoad

NOW = datetime.now().strftime("%Y%m%d")


def main():
    parser = argparse.ArgumentParser(
        prog="somisana",
        description="SOMISANA TOOLKIT"
    )

    # --version
    parser.add_argument("-v", "--version", action="version", version="0.0.1")

    # SUB COMMANDS
    module_parser = parser.add_subparsers(
        title="Toolkit modules",
        description="Sub-programs that are part of the SOMISANA toolkit",
        dest="command",
        metavar="Available commands"
    )

    # LACCE module
    lacce_module = module_parser.add_parser("lacce", help="LACCE module")
    lacce_module.add_argument("item", help="Item to add")

    # MHW module
    mhw = module_parser.add_parser("mhw", help="Marine Heat Waves (MHW) module")
    mhw_parser = mhw.add_subparsers(
        title="Marine Heat Waves (MHW)",
        description="Look for high normal variance of SST compared to the previous decades",
        dest="mhw_command",
        metavar="Available commands"
    )
    mhw_download = mhw_parser.add_parser("download", help="Download NOAA data")
    mhw_download.add_argument("-d", "--date-range", help="Date range")
    mhw_thresholds = mhw_parser.add_parser(
        "thresholds", help="Determine thresholds from downloaded NetCDF file"
    )
    mhw_thresholds.add_argument("-i", "--input-path", help="Input data")
    mhw_detect = mhw_parser.add_parser("detect", help="Detect heat-wave events")
    mhw_detect.add_argument(
        "-i", "--input-path", help="Operational data input (NetCDF file)"
    )
    mhw_detect.add_argument(
        "-t", "--thresholds-input-path", help="Threshold data input (NetCDF file)"
    )

    # Operational forecasts module (ops)
    ops = module_parser.add_parser("ops", help="CROCO Operational Models module")
    ops_parser = ops.add_subparsers(
        title="Operational ocean forecasting",
        description="Run localised, high resolution ocean forecasts using the CROCO modelling suite",
        dest="ops_command",
        metavar="Available commands"
    )
    ops_download = ops_parser.add_parser(
        "download", help="Download forcing input files"
    )
    ops_download.add_argument(
        "--workdir", default=".output", help="Directory output of forcing files"
    )
    ops_download.add_argument(
        "--matlab-env", default=".output/.env", help="Path to MatLab configuration file"
    )
    ops_download.add_argument(
        "--download-date", default=NOW, help="Download date (yyyymmdd)"
    )
    ops_download.add_argument(
        "--gfs", action="store_true", default=False, help="Dwonload GFS data"
    )
    ops_download.add_argument(
        "--mercator", action="store_true", default=False, help="Download Mercator data"
    )
    ops_download.add_argument(
        "--domain",
        help="Bounding box in 4326 projection (i.e. min_long,max_long,min_lat,max_lat)",
    )
    ops_transform = ops_parser.add_parser(
        "transform", help="Normalize model output grids"
    )
    ops_transform.add_argument("--nc-input-path", help="Path of NetCDF input file")
    ops_transform.add_argument(
        "--nc-output-path", default=".output.nc", help="Path of NetCDF output path"
    )
    ops_transform.add_argument(
        "--zarr-output-path", default=".output.zarr", help="Path of Zarr output path"
    )
    ops_transform.add_argument(
        "--grid-input-path", help="Path of NetCDF grid input path"
    )
    ops_load = ops_parser.add_parser("load", help="Download forcing input files")
    ops_load.add_argument(
        "--upsert-rasters",
        action="store_true",
        default=False,
        help="Run the raster2pgsql script",
    )
    ops_load.add_argument(
        "--upsert-coordinates",
        action="store_true",
        default=False,
        help="Refresh the coordinates of the grid",
    )
    ops_load.add_argument(
        "--upsert-values",
        action="store_true",
        default=False,
        help="Refresh the coordinates of the grid",
    )
    ops_load.add_argument("--depths", help="Depth level range to refresh (i.e. '1,5')")
    ops_load.add_argument(
        "--model", help="The name of the model data is being loaded for"
    )
    ops_load.add_argument(
        "--drop-db",
        action="store_true",
        default=False,
        help="Drop and recreate the DB. (PY_ENV == development only)",
    )
    ops_load.add_argument(
        "--install-db",
        action="store_true",
        default=False,
        help="Run the idempotent schema install script",
    )
    ops_load.add_argument("--run-date", default=NOW, help="Run date (yyyymmdd)")
    ops_load.add_argument("--model-data", help="Path of NetCDF input file")
    ops_load.add_argument(
        "--reload-data",
        action="store_true",
        default=False,
        help="Path of NetCDF input file",
    )
    ops_load.add_argument(
        "--finalize-run",
        action="store_true",
        default=False,
        help="Remove temp rasters, re-analyze tables, and mark run as finished",
    )

    # parse the arguments
    args = parser.parse_args()

    # OPERATIONAL MODELS
    if args.command == "ops":
        if args.ops_command == "download":
            opsDownload(args)
            return
        if args.ops_command == "transform":
            opsTransform(args)
            return
        if args.ops_command == "load":
            opsLoad(args)
            return

    # MHW
    if args.command == "mhw":
        if args.mhw_command == "download":
            date_range = args.data_range
            print("mhw -> download -> date range", date_range)
            return
        if args.mhw_command == "thresholds":
            input_path = args.input_path
            print("mhw -> thresholds -> input path", input_path)
            return
        if args.mhw_command == "detect":
            input_path = args.input_path
            thresholds_input_path = args.thresholds_input_path
            print("mhw -> detect -> thresholds", input_path, thresholds_input_path)
            return

    # LACCE
    if args.command == "lacce":
        print(f"Adding item: {args.item}")
        return

    # Otherwise print help
    parser.print_help()


if __name__ == "__main__":
    main()
    exit(0)
