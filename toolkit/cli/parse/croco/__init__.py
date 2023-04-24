def parse(cmd, args, module):
    commands = {
        "post-process-v1": module.post_process_v1,
        "post-process-v2": module.post_process_v2,
        "load-pp-v1-output-to-pg": module.load_pp_v1_output_to_pg,
    }

    def e(*args):
        print(cmd.format_help())
        exit()

    return commands.get(args.croco_command, e)
