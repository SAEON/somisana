import argparse
import os
import cli.define as define
import cli.parse as parse
import cli.applications as apps

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

    # (1) Build applications
    app_objects = {
        "download": (
            getattr(getattr(define, "download"), "build")(module_parser),
            apps.download,
        ),
        "mhw": (getattr(getattr(define, "mhw"), "build")(module_parser), apps.mhw),
        "lacce": (
            getattr(getattr(define, "lacce"), "build")(module_parser),
            apps.lacce,
        ),
        "kerchunk": (
            getattr(getattr(define, "kerchunk"), "build")(module_parser),
            apps.kerchunk,
        ),
        "update": (
            getattr(getattr(define, "update"), "build")(module_parser),
            apps.update,
        ),
        "pg": (getattr(getattr(define, "pg"), "build")(module_parser), apps.pg),
        "croco": (
            getattr(getattr(define, "croco"), "build")(module_parser),
            apps.croco,
        ),
    }

    # (2) Parse command string
    args = parser.parse_args()

    # (4) Retrieve the specific applications function to run from commands and flags
    try:
        app, data = app_objects[args.command]
        exe = getattr(getattr(parse, args.command), "parse")(app, args, data)
    except:
        exe = None

    # (5) Execute the application
    if not exe:
        parser.print_help()
        return
    else:
        exe(args)


if __name__ == "__main__":
    main()
