def build(module_parser):
    pg = module_parser.add_parser("pg", help="PostGIS module")
    pg_parser = pg.add_subparsers(
        title="PostgreSQL (+ PostGIS)",
        description="Tools for interacting with a PostGIS instance",
        dest="pg_command",
        metavar="Available commands",
    )

    # prune-values (no flags)
    pg_parser.add_parser(
        "prune-values", help="Prune partitions of model data older than 10 days"
    )

    # Load post processing V1 to PostgreSQL
    load_croco_tier1_output_to_pg = pg_parser.add_parser(
        "load-croco-tier1-output-to-pg",
        help="Load CROCO post processing output (v1) to PostgreSQL",
    )
    load_croco_tier1_output_to_pg.add_argument(
        "--input",
        type=str,
        help="Path to post-processed (v1) NetCDF file",
        default=".output/croco/post-process-v1-output.nc",
    )
    load_croco_tier1_output_to_pg.add_argument(
        "--parallelization",
        type=int,
        default=4,
        help="How many instances of the load query to run in parallel",
    )

    return pg
