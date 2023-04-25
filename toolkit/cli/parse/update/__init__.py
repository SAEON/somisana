def parse(cmd, args, module):
    def e(*args):
        print(cmd.format_help())
        exit()

    try:
        version = args.version
        reset = args.reset

        if reset and version:
            raise Exception("Please specify either reset or version flags")

        if version or reset:
            return module.update_bashrc

    except Exception as err:
        print(err)
        return e
