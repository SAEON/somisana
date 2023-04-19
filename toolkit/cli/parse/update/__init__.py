def parse(cmd, args, module):
    version = args.version
    reset = args.reset
    if reset and version:
        raise Exception("Please specify either reset or version flags")
    if version or reset:
        return module.update_bashrc
    else:

        def e(*args):
            print(cmd.format_help())
            exit()

        return e
