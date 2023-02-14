from cli.modules.mhw import start

def run(cmd, args):
    if args.mhw_command == "start":
        start(args)
    else:
        print(cmd.format_help())