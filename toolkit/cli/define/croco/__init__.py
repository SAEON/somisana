def build(module_parser):
    croco = module_parser.add_parser("croco", help="CROCO module")
    croco_parser = croco.add_subparsers(
        title="CROCO",
        description="CROCO-tooling",
        dest="croco_command",
        metavar="Available commands",
    )

    # Post processing V1
    croco_post_process_v1 = croco_parser.add_parser(
        "post-process-v1", help="Post processing functions"
    )
    croco_post_process_v1.add_argument(
        "--nc-input-path", help="Path of CROCO output file", required=True
    )
    croco_post_process_v1.add_argument(
        "--nc-output-path", default=".output.nc", help="Path of processed output path"
    )
    croco_post_process_v1.add_argument(
        "--grid-input-path", help="Path of NetCDF grid input path", required=True
    )

    # Post processing V2
    croco_post_process_v2 = croco_parser.add_parser(
        "post-process-v2", help="Post processing functions"
    )
    croco_post_process_v2.add_argument(
        "--input",
        default=".input",
        help="Some input path",
    )

    # Load post processing V1 to PostgreSQL
    croco_load_pp_v1_output_to_pg = croco_parser.add_parser(
        "load-pp-v1-output-to-pg", help="Load post processing output (v1) to PostgreSQL"
    )
    croco_load_pp_v1_output_to_pg.add_argument(
        "--processed-netcdf-file",
        type=str,
        default=".ppv1-output.netcdf",
        help="Path to post-processed (v1) NetCDF file",
    )
    return croco
