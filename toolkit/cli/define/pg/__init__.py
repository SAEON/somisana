def build(module_parser):
    pg = module_parser.add_parser("pg", help="PostGIS module")
    pg_parser = pg.add_subparsers(
        title="PostgreSQL (+ PostGIS)",
        description="Tools for interacting with a PostGIS instance",
        dest="pg_command",
        metavar="Available commands",
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
    return pg
