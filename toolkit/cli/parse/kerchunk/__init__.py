def parse(cmd, args, module):
    if args.kerchunk_command == "run":
        return module.run
    else:
        print(cmd.format_help())
