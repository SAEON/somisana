def parse(cmd, args, module):
    if args.mhw_command == "start":
        return module.start
    else:
        print(cmd.format_help())
