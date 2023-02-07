from cli.ops.load.values.load_band import load


def upsert(runid, start_time, depths, datetimes, total_depth_levels):
    start_depth, end_depth = depths.split(",")

    depth_levels = [*range(int(start_depth), int(end_depth) + 1, 1)]
    for depth_level in depth_levels:
        load(depth_level, runid, start_time, datetimes, total_depth_levels)
