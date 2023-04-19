def parse(cmd, args, module):
    if args.pg_command == "raster2pgsql":
        return module.raster2pgsql
    print(cmd.format_help())
