from postgis import pool
from cli.load.values.load_band import load


def upsert(model, run_date, start_time, depths, datetimes):
    start_depth, end_depth = depths.split(",")

    # Resolve the modelid from the name
    modelid = None
    with pool().connection() as client:
        cursor = client.execute("""select id from models where name = %s""", (model,))
        modelid = cursor.fetchall()[0][0]

    depth_levels = [*range(int(start_depth), int(end_depth), 1)]
    for depth_level in depth_levels:
        load(modelid, depth_level, run_date, start_time, datetimes)
