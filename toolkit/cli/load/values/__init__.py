from postgis import connect
from cli.load.values.load_depth_level import load as load_timestep
from multiprocessing import Pool, cpu_count


def upsert(model, run_date, start_time, config):
    total_depth_levels = config[model]['depth']['levels']
    
    # Resolve the modelid from the name
    cursor = connect().cursor()
    cursor.execute("""select id from models where name = %s""", (model,))
    modelid = cursor.fetchall()[0][0]

    depth_levels = [*range(1, total_depth_levels + 1, 1)]

    cores = cpu_count()
    print('Running on multiple cores:', cores)

    with Pool(processes=cores) as pool:
        pool.starmap(load_timestep, list(map(lambda d: [d, run_date, start_time, modelid], depth_levels)))
