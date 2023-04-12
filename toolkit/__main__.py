import argparse
import os
from cli.define import (
    lacce as define_lacce,
    mhw as define_mhw,
    ops as define_ops,
    kerchunk as define_kerchunk,
    update as define_update,
)
from cli.parse import (
    lacce as parse_lacce,
    mhw as parse_mhw,
    ops as parse_ops,
    kerchunk as parse_kerchunk,
    update as parse_update,
)
from cli.applications import (
    lacce,
    mhw,
    ops,
    kerchunk,
    update,
)

prog = "somisana"
description = "SOMISANA Toolkit"
version = os.getenv("TOOLKIT_VERSION", "development")


def main():
    parser = argparse.ArgumentParser(prog=prog, description=description)
    parser.add_argument("-v", "--version", action="version", version=version)
    module_parser = parser.add_subparsers(
        title="Toolkit modules",
        description="Sub-programs that are part of the SOMISANA toolkit",
        dest="command",
        metavar="Applications",
    )

    # (1) Build commands
    mhw_app = define_mhw.build(module_parser)
    ops_app = define_ops.build(module_parser)
    lacce_app = define_lacce.build(module_parser)
    kerchunk_app = define_kerchunk.build(module_parser)
    update_app = define_update.build(module_parser)

    # (2) Parse command string
    args = parser.parse_args()

    # (3) Select the application by parsing flag options
    exe = (
        parse_ops.parse(ops_app, args, ops)
        if args.command == "ops"
        else parse_mhw.parse(mhw_app, args, mhw)
        if args.command == "mhw"
        else parse_lacce.parse(lacce_app, args, lacce)
        if args.command == "lacce"
        else parse_kerchunk.parse(kerchunk_app, args, kerchunk)
        if args.command == "kerchunk"
        else parse_update.run(update_app, args, update)
        if args.command == "update"
        else None
    )

    # (4) Execute the application
    if not exe:
        parser.print_help()
        return
    else:
        exe(args)


if __name__ == "__main__":
    main()
