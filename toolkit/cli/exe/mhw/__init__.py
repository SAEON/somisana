from cli.modules.mhw import download

def run(cmd, args):
    if args.mhw_command == "download":
        download(args)
    elif args.mhw_command == "thresholds":
        print('TODO')
    elif args.mhw_command == "detect":
        print('TODO')
    else:
        print(cmd.format_help())