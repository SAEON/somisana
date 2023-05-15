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
        "--id",
        type=str,
        help="Name / ID of the model being post-processed. This gets included as a global attribute in the output",
        required=True,
    )
    croco_post_process_v1.add_argument(
        "--grid", type=str, help="Path of NetCDF grid input path", required=True
    )
    croco_post_process_v1.add_argument(
        "--input", type=str, help="Path of CROCO output file", required=True
    )
    croco_post_process_v1.add_argument(
        "--output",
        type=str,
        help="Path of processed output path",
        default=".output/croco/post-process-v1-output.nc",
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
        "--grid", type=str, help="Path of NetCDF grid input path", required=True
    )
    croco_post_process_v2.add_argument(
        "--input", type=str, help="Path of CROCO output file", required=True
    )
    croco_post_process_v2.add_argument(
        "--output",
        type=str,
        help="Path of processed output path",
        default=".output/croco/post-process-v2-output.nc",
    )

    return croco
