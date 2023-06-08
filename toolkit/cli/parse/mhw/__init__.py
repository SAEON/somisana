def parse(cmd, args, module):
    commands = {"update-catalogue": module.update_catalogue, "detect": module.detect}

    def e(*args):
        print(cmd.format_help())
        exit()

    return commands.get(args.mhw_command, e)
