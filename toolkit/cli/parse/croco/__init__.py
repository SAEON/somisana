from datetime import datetime


def parse(cmd, args, module):
    def e(*args):
        print(cmd.format_help())
        exit()

    try:
        commands = {
            "post-process-v1": module.post_process_v1,
            "post-process-v2": module.post_process_v2,
            "load-pp-v1-output-to-pg": module.load_pp_v1_output_to_pg,
        }

        # Validate args
        if hasattr(args, "run_date"):
            try:
                datetime.strptime(args.run_date, "%Y%m%d")
            except:
                raise Exception("Expected date format for --run-date is %Y%m%d")

        # Return the command
        return commands.get(args.croco_command, e)

    except Exception as err:
        print(err)
        return e
