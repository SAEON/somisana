def build(module_parser):
    update = module_parser.add_parser("update", help="Update the SOMISANA CLI")
    update.add_argument(
        "--version",
        type=str,
        help="Update the CLI to the version specified (specify a label of the somisana_toolkit_stable image)",
    )
    update.add_argument(
        "--reset",
        action="store_true",
        default=False,
        help="Rest to the original installed version of the CLI",
    )
    return update
