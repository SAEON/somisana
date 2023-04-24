def parse(cmd, args, module):
    if args.ops_command == "download":
        return module.download
    else:

        def e(*args):
            print(cmd.format_help())
            exit()

        return e
