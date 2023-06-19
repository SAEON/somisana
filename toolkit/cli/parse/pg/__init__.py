def parse(cmd, args, module):
    commands = {
        "prune-values": module.prune_values,
        "load-croco-tier1-output-to-pg": module.load_croco_tier1_output_to_pg,
    }

    def e(*args):
        print(cmd.format_help())
        exit()

    return commands.get(args.pg_command, e)
