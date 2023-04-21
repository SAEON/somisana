def build(module_parser):
    pg = module_parser.add_parser("pg", help="PostGIS module")
    pg_parser = pg.add_subparsers(
        title="PostgreSQL (+ PostGIS)",
        description="Tools for interacting with a PostGIS instance",
        dest="pg_command",
        metavar="Available commands",
    )

    # register-model
    pg_register_model = pg_parser.add_parser(
        "register-model",
        help="Register an operational model for use by the UI visualization tools",
    )
    pg_register_model.add_argument(
        "--id",
        type=str,
        help="ID of the model configuration in the models.json file. For now, that file has to be adjusted in source",
        required=True,
    )

    # schema
    pg_schema = pg_parser.add_parser("schema", help="Install the PostGIS schema")
    pg_schema.add_argument(
        "--drop",
        action="store_true",
        default=False,
        help="Drop the schema and recreate it. This is destructive and will lose data",
    )
    pg_schema.add_argument(
        "--create",
        action="store_true",
        default=True,
        help="Create the schema (non-destructive and idempotent). Defaults to True",
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
