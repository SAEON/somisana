def parse(cmd, args, module):
    def e(*args):
        print(cmd.format_help())
        exit()

    try:
        return module.download
    except Exception as e:
        print(e)
        return e
