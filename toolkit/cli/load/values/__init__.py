from postgis import pool
from cli.load.values.load_band import load
from multiprocessing import Pool, cpu_count


def upsert(model, run_date, start_time, config):
    total_depth_levels = config[model]["depth"]["levels"]

    # Resolve the modelid from the name
    modelid = None
    with pool.connection() as client:
        cursor = client.execute("""select id from models where name = %s""", (model,))
        modelid = cursor.fetchall()[0][0]

    depth_levels = [*range(1, total_depth_levels + 1, 1)]
    print(depth_levels)

    cores = cpu_count()
    print("Running on multiple cores:", cores)

    with Pool(processes=cores) as cpuPool:
        cpuPool.starmap(
            load,
            list(
                map(
                    lambda depth_level: [depth_level, run_date, start_time, modelid],
                    depth_levels,
                )
            ),
        )
