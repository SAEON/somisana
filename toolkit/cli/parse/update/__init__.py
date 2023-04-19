def parse(cmd, args, module):
    version = args.version
    reset = args.reset
    if reset and version:
        raise Exception("Please specify either reset or version flags")
    if version or reset:
        return module.update_bashrc
    print(cmd.format_help())
