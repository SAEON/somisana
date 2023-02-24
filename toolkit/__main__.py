import argparse
from cli.commands import (
    lacce as lacce_cmd,
    mhw as mhw_cmd,
    ops as ops_cmd,
    kerchunk as kerchunk_cmd,
)
from cli.exe import (
    lacce as lacce_exe,
    mhw as mhw_exe,
    ops as ops_exe,
    kerchunk as kerchunk_exe,
)

prog = "somisana"
description = "SOMISANA Toolkit"
version = "0.0.1"


def main():
    parser = argparse.ArgumentParser(prog=prog, description=description)
    parser.add_argument("-v", "--version", action="version", version=version)
    module_parser = parser.add_subparsers(
        title="Toolkit modules",
        description="Sub-programs that are part of the SOMISANA toolkit",
        dest="command",
        metavar="Applications",
    )

    # Build commands
    mhw = mhw_cmd.build(module_parser)
    ops = ops_cmd.build(module_parser)
    lacce = lacce_cmd.build(module_parser)
    kerchunk = kerchunk_cmd.build(module_parser)

    # Parse args
    args = parser.parse_args()

    # Run the CLI
    if args.command == "ops":
        ops_exe.run(ops, args)
    elif args.command == "mhw":
        mhw_exe.run(mhw, args)
    elif args.command == "lacce":
        lacce_exe.run(lacce, args)
    elif args.command == "kerchunk":
        kerchunk_exe.run(kerchunk, args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
