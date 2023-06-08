def parse(cmd, args, module):
    commands = {
        "update-catalogue": module.update_catalogue,
    }

    def e(*args):
        print(cmd.format_help())
        exit()

    return commands.get(args.mhw_command, e)
