def build(module_parser):
    pg = module_parser.add_parser("pg", help="PostGIS module")
    pg_parser = pg.add_subparsers(
        title="PostgreSQL (+ PostGIS)",
        description="Tools for interacting with a PostGIS instance",
        dest="pg_command",
        metavar="Available commands",
    )

    # raster2pgsql
    pg_raster2pgsql = pg_parser.add_parser(
        "raster2pgsql", help="Run PostGIS raster2pgsql function"
    )
    pg_raster2pgsql.add_argument(
        "--input",
        default=".input",
        help="Path of raster input file",
    )
    return pg
