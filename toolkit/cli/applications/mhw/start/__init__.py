from cli.applications.mhw.thresholds import create_thresholds


def start(args):
    create_thresholds(args)
    print("Complete!")