from cli.modules.update.update_bashrc import update_bashrc


def run(cmd, args):
    version = args.version
    reset = args.reset
    if reset and version:
        raise Exception("Please specify either reset or version flags")

    if version or reset:
        update_bashrc(args)
        return
    print(cmd.format_help())
