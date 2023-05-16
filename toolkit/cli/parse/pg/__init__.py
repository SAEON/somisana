def parse(cmd, args, module):
    commands = {
        "prune-values": module.prune_values,
        "load-croco-pp-v1-output-to-pg": module.load_croco_pp_v1_output_to_pg,
    }

    def e(*args):
        print(cmd.format_help())
        exit()

    return commands.get(args.pg_command, e)
