from environs import Env
env = Env()

PG_HOST = env.str('PG_HOST', 'localhost')
PG_PORT = env.int('PG_PORT', 5432)
PG_DB = env.str('PG_DB', 'somisana_local')
PG_USERNAME = env.str('PG_USERNAME', 'admin')
PG_PASSWORD = env.str('PG_PASSWORD', 'password')

MONGO_HOST = env.str('MONGO_HOST', 'localhost:27017')
MONGO_DB = env.str('MONGO_DB', 'somisana_local') 
MONGO_USERNAME = env.str('MONGO_USERNAME', 'admin')
MONGO_PASSWORD = env.str('MONGO_PASSWORD', 'password')

MODEL_OUTPUT_PATH = env.str('MODEL_OUTPUT_PATH', 'avg.nc output file path')
GRID_PATH = env.str('GRID_PATH','grd.nc model grid file path')
NC_OUTPUT_DIR = env.str('NC_OUTPUT_DIR', 'avg_transformed.nc transformed output file path')