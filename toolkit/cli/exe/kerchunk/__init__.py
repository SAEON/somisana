from cli.modules.kerchunk import run as run_kerchunker

def run(cmd, args):
    if args.kerchunk_command == "run":
        run_kerchunker(args)
    else:
        print(cmd.format_help())