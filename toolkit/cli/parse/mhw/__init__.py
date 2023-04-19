def parse(cmd, args, module):
    if args.mhw_command == "start":
        return module.start
    else:

        def e(*args):
            print(cmd.format_help())
            exit()

        return e
