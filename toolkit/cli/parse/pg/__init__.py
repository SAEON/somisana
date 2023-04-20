def parse(cmd, args, module):
    if args.pg_command == "raster2pgsql":
        return module.raster2pgsql
    elif args.pg_command == "schema":
        return module.schema
    else:

        def e(*args):
            print(cmd.format_help())
            exit()

        return e
