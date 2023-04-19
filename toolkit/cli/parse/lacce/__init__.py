def parse(cmd, args, module):
    input = args.input
    output = args.output
    if input and output:
        print("LACCE", input, output)
        return lambda: print("Not implemented")
    else:

        def e(*args):
            print(cmd.format_help())
            exit()

        return e
