# To register a new app (i.e. a top level CLI command), add code to the "define",
# "parse", and "applications" folders. Look at other examples in those folders
# for the required signatures. You should not need to update this file to create
# additional CLI commands

import argparse
import os
import cli.define as define
import cli.parse as parse
import cli.applications as apps

REGISTERED_APPS = apps.__all__

# Validate that define, parse, applications are all exporting the same modules. This is required to
# build the CLI correctly
if not sorted(define.__all__) == sorted(parse.__all__) == sorted(apps.__all__):
    raise Exception(
        "Please check the __all__ exports in the top level cli module exports. They should be equivalent"
    )

prog = "somisana"
description = "SOMISANA Toolkit"
version = os.getenv("TOOLKIT_VERSION", "development")
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
    app: (
        getattr(getattr(define, app), "build")(module_parser),
        getattr(apps, app),
    )
    for app in REGISTERED_APPS
}

# (2) Parse command string
args = parser.parse_args()

# (3) Retrieve the specific applications function to run from commands and flags
try:
    app, data = app_objects[args.command]
    exe = getattr(getattr(parse, args.command), "parse")(app, args, data)
except:
    exe = None

# (4) Execute the application
if not exe:
    parser.print_help()
else:
    exe(args)
