from datetime import datetime


def parse(cmd, args, module):
    def e(*args):
        print(cmd.format_help())
        exit()

    try:
        commands = {
            "regrid-tier1": module.regrid_tier1,
            "regrid-tier2": module.regrid_tier2,
            "regrid-tier3": module.regrid_tier3,
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
