def parse(cmd, args, module):
    if args.ops_command == "download":
        return module.download
    elif args.ops_command == "transform":
        return module.transform
    elif args.ops_command == "load":
        return module.load
    else:
        print(cmd.format_help())
