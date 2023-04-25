from datetime import datetime

NOW = datetime.now().strftime("%Y%m%d")


def build(module_parser):
    download = module_parser.add_parser(
        "download", help="Download boundary conditions and forcing files"
    )
    download.add_argument(
        "--workdir", default=".output", help="Directory output of forcing files"
    )
    download.add_argument(
        "--matlab-env", default=".output/.env", help="Path to MatLab configuration file"
    )
    download.add_argument(
        "--download-date", default=NOW, help="Download date (yyyymmdd)"
    )
    download.add_argument(
        "--provider",
        type=str,
        choices=["gfs", "mercator"],
        help="Forcing data provider",
        required=True,
    )
    download.add_argument(
        "--hdays",
        type=int,
        default=5,
        help="Hindcast download days",
    )
    download.add_argument(
        "--fdays",
        type=int,
        default=5,
        help="Forecast download days",
    )
    download.add_argument(
        "--domain",
        help="Bounding box in 4326 projection (i.e. min_long,max_long,min_lat,max_lat)",
        required=True,
    )
    return download
