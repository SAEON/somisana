def build(module_parser):
    croco = module_parser.add_parser("croco", help="CROCO module")
    croco_parser = croco.add_subparsers(
        title="CROCO",
        description="CROCO-tooling",
        dest="croco_command",
        metavar="Available commands",
    )

    # Post processing script(s?)
    croco_post_processing = croco_parser.add_parser(
        "process", help="Post processing functions"
    )
    croco_post_processing.add_argument(
        "--input",
        default=".input",
        help="Some input path",
    )
    return croco
