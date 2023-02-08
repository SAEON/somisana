def run(cmd, args):
    if args.mhw_command == "download":
        date_range = args.data_range
        print("mhw -> download -> date range", date_range)
        return
    if args.mhw_command == "thresholds":
        input_path = args.input_path
        print("mhw -> thresholds -> input path", input_path)
        return
    if args.mhw_command == "detect":
        input_path = args.input_path
        thresholds_input_path = args.thresholds_input_path
        print("mhw -> detect -> thresholds", input_path, thresholds_input_path)
        return
    print(cmd.format_help())