from datetime import datetime

NOW = datetime.now().strftime("%Y%m%d")


def build(module_parser):
    ops = module_parser.add_parser("ops", help="CROCO Operational Models module")
    ops_parser = ops.add_subparsers(
        title="Operational ocean forecasting",
        description="Run localised, high resolution ocean forecasts using the CROCO modelling suite",
        dest="ops_command",
        metavar="Available commands",
    )

    # DOWNLOAD
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
        "--provider",
        type=str,
        choices=["gfs", "mercator"],
        help="Forcing data provider",
        required=True,
    )
    ops_download.add_argument(
        "--domain",
        help="Bounding box in 4326 projection (i.e. min_long,max_long,min_lat,max_lat)",
        required=True,
    )

    # TRANSFORM (process CROCO output)
    ops_transform = ops_parser.add_parser(
        "transform", help="Normalize model output grids"
    )
    ops_transform.add_argument(
        "--nc-input-path", help="Path of NetCDF input file", required=True
    )
    ops_transform.add_argument(
        "--nc-output-path", default=".output.nc", help="Path of NetCDF output path"
    )
    ops_transform.add_argument(
        "--zarr-output-path", default=".output.zarr", help="Path of Zarr output path"
    )
    ops_transform.add_argument(
        "--grid-input-path", help="Path of NetCDF grid input path", required=True
    )

    # LOAD (to Zarr server and/or PostgeSQL)
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
    return ops
