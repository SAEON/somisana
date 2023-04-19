def parse(cmd, args, module):
    if args.croco_command == "process":
        return module.process
    else:

        def e(*args):
            print(cmd.format_help())
            exit()

        return e
