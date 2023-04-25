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
if not sorted(define.__all__) == sorted(parse.__all__) == sorted(REGISTERED_APPS):
    raise Exception(
        "Please check the __all__ exports in the top level cli module exports. They should be equivalent"
    )

prog = "somisana"
description = "SOMISANA Toolkit"
version = os.getenv("TOOLKIT_VERSION", "development")

cli = argparse.ArgumentParser(prog=prog, description=description)
cli.add_argument("-v", "--version", action="version", version=version)
cmds = cli.add_subparsers(
    title="Toolkit modules",
    description="Sub-programs that are part of the SOMISANA toolkit",
    dest="command",
    metavar="Applications",
)

# (1) Build applications
app_library = {
    app: (
        getattr(getattr(define, app), "build")(cmds),
        getattr(apps, app),
    )
    for app in REGISTERED_APPS
}

# (2) Parse command string
args = cli.parse_args()

# (3) Retrieve the specific applications function to run from commands and flags
exe = None
try:
    app, data = app_library[args.command]
    exe = getattr(getattr(parse, args.command), "parse")(app, args, data)
except Exception as e:
    print(e)

# (4) If the commands are incorrect print help
if not exe:
    cli.print_help()
    exit()

# (5) Execute the application
exe(args)
