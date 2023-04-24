def parse(cmd, args, module):
    commands = {
        "raster2pgsql": module.raster2pgsql,
        "schema": module.schema,
        "register-model": module.register_model,
    }

    def e(*args):
        print(cmd.format_help())
        exit()

    return commands.get(args.pg_command, e)
