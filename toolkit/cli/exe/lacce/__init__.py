def run(cmd, args):
    input = args.input
    output = args.output
    if input and output:
        print("LACCE", input, output)
        return
    print(cmd.format_help())
