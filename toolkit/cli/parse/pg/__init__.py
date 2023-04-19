def parse(cmd, args, module):
    if args.pg_command == "raster2pgsql":
        return module.raster2pgsql
    else:

        def e(*args):
            print(cmd.format_help())
            exit()

        return e
