def parse(cmd, args, module):
    def e(*args):
        print(cmd.format_help())
        exit()

    try:
        cmds = {"start": module.start}
        return cmds.get(args.mhw_command, e)
    except Exception as err:
        print(err)
        return e
