def parse(cmd, args, module):
    input = args.input
    output = args.output
    if input and output:
        return module.zarrify
    else:

        def e(*args):
            print(cmd.format_help())
            exit()

        return e
