from cli.modules.ops import download, load, transform


def run(cmd, args):
    if args.ops_command == "download":
        download(args)
    elif args.ops_command == "transform":
        transform(args)
    elif args.ops_command == "load":
        load(args)
    else:
        print(cmd.format_help())
