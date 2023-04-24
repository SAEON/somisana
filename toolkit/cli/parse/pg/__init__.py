def parse(cmd, args, module):
    commands = {
        "schema": module.schema,
    }

    def e(*args):
        print(cmd.format_help())
        exit()

    return commands.get(args.pg_command, e)
