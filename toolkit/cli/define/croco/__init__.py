from datetime import datetime


def build(module_parser):
    croco = module_parser.add_parser("croco", help="CROCO module")
    croco_parser = croco.add_subparsers(
        title="CROCO",
        description="CROCO-tooling",
        dest="croco_command",
        metavar="Available commands",
    )

    """
    Regridding tier 1:
      -> Regrids u/v to the density (rho) grid
      -> rotates u/v to be east/north components instead of grid-aligned components
      -> Adds depths to the sigma levels at each time-step
      -> NOT CF compliant (I don't think)
      -> Outputs:
        -> zeta
        -> temperature
        -> salt
        -> u (re-gridded and rotated)
        -> v (re-gridded and rotated)
        -> depth
        -> h
        -> lon_rho
        -> lat_rho
        -> time
    """
    regrid_tier1 = croco_parser.add_parser(
        "regrid-tier1", help="Post processing functions"
    )
    regrid_tier1.add_argument(
        "--id",
        type=str,
        help="Name / ID of the model being post-processed. This gets included as a global attribute in the output",
        required=True,
    )
    regrid_tier1.add_argument(
        "--grid", type=str, help="Path of NetCDF grid input path", required=True
    )
    regrid_tier1.add_argument(
        "--input", type=str, help="Path of CROCO output file", required=True
    )
    regrid_tier1.add_argument(
        "--run-date",
        type=str,
        default=datetime.now().strftime("%Y%m%d"),
        help="Date of model run (yyyymmdd)",
    )
    regrid_tier1.add_argument(
        "--output",
        type=str,
        help="Path of processed output file",
        default=".output/croco/regridded-tier1-output.nc",
    )

    """
    Regridding tier 2:
      -> takes the output of regrid-tier1 as input and
      -> regrids the sigma levels to constant z levels, including the surface and bottom layers
      -> output variables are the same as tier 1, only depths are constant values
    """
    regrid_tier2 = croco_parser.add_parser(
        "regrid-tier2", help="Post processing functions"
    )
    regrid_tier2.add_argument(
        "--input", type=str, help="Path of output file from regrid-tier1", required=True
    )
    regrid_tier2.add_argument(
        "--depths",
        type=str,
        help="comma separated depth levels (in metres, positive down) to interpolate to (a value of 99999 is used to indicate the bottom layer)",
        default="0,1,2,5,10,15,20,30,40,50,60,70,100,150,200,500,1000,1500,2000,99999",
    )
    regrid_tier2.add_argument(
        "--output",
        type=str,
        help="Path of processed output file",
        default=".output/croco/regridded-tier2-output.nc",
    )

    """
    Regridding tier 3:
      -> takes the output of regrid-tier2 as input and
      -> regrids the horizontal grid to be regular with a specified grid spacing
      -> output variables are the same as tier 1 and 2, only horizontal grid is constant
    """
    regrid_tier3 = croco_parser.add_parser(
        "regrid-tier3", help="Post processing functions"
    )
    regrid_tier3.add_argument(
        "--input", type=str, help="Path of output file from regrid-tier2", required=True
    )
    regrid_tier3.add_argument(
        "--output",
        type=str,
        help="Path of processed output file",
        default=".output/croco/regridded-tier3-output.nc",
    )
    regrid_tier3.add_argument(
        "--spacing",
        type=str,
        help="constant horizontal grid spacing (in degrees) to be used for the interpolated output",
        default="0.01",
    )

    return croco
