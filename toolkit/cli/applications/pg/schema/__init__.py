from postgis import drop, setup
from lib.log import log


def schema(args):
    log("Updating schema...")
    drop_schema = args.drop
    create_schema = args.create
    if drop_schema:
        drop()
    if create_schema:
        setup()
    log("Complete")
