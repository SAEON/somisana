def parse(cmd, args, module):
    command_mapping = {
        "raster2pgsql": module.raster2pgsql,
        "schema": module.schema,
        "register-model": module.register_model,
    }

    def e(*args):
        print(cmd.format_help())
        exit()

    return command_mapping.get(args.pg_command, e)
