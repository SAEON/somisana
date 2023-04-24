def build(module_parser):
    croco = module_parser.add_parser("croco", help="CROCO module")
    croco_parser = croco.add_subparsers(
        title="CROCO",
        description="CROCO-tooling",
        dest="croco_command",
        metavar="Available commands",
    )

    """
    Post-processing V1:
      -> Aligns u/v grid with density (rho) grid
      -> Adds z-levels to data
      -> NOT CF compliant (I don't think)
      -> Outputs:
        -> temperature
        -> salt
        -> u (re-aligned)
        -> v (re-aligned)
        -> m_rho
        -> h
        -> lon_rho
        -> lat_rho
        -> depth
        -> time (steps in hours)
    """
    croco_post_process_v1 = croco_parser.add_parser(
        "post-process-v1", help="Post processing functions"
    )
    croco_post_process_v1.add_argument(
        "--grid", help="Path of NetCDF grid input path", required=True
    )
    croco_post_process_v1.add_argument(
        "--input", help="Path of CROCO output file", required=True
    )
    croco_post_process_v1.add_argument(
        "--output",
        help="Path of processed output path",
        default=".output/toolkit/post-process-v1-output.nc",
    )

    """
    Post-processing V2:
      -> Aligns u/v grid with density (rho) grid
      -> ... ? TODO
    """
    croco_post_process_v2 = croco_parser.add_parser(
        "post-process-v2", help="Post processing functions"
    )
    croco_post_process_v2.add_argument(
        "--grid", help="Path of NetCDF grid input path", required=True
    )
    croco_post_process_v2.add_argument(
        "--input", help="Path of CROCO output file", required=True
    )
    croco_post_process_v2.add_argument(
        "--output",
        help="Path of processed output path",
        default=".output/toolkit/post-process-v2-output.nc",
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
