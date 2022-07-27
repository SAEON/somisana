from environs import Env
from os import getcwd, path
env = Env()

PY_ENV = env.str('PY_ENV', 'development')

PG_HOST = env.str('PG_HOST', 'localhost')
PG_PORT = env.int('PG_PORT', 5432)
PG_DB = env.str('PG_DB', 'somisana_local')
PG_USERNAME = env.str('PG_USERNAME', 'admin')
PG_PASSWORD = env.str('PG_PASSWORD', 'password')

MONGO_HOST = env.str('MONGO_HOST', 'localhost:27017')
MONGO_DB = env.str('MONGO_DB', 'somisana_local') 
MONGO_USERNAME = env.str('MONGO_USERNAME', 'admin')
MONGO_PASSWORD = env.str('MONGO_PASSWORD', 'password')

COPERNICUS_USERNAME = env.str('COPERNICUS_USERNAME','default username')
COPERNICUS_PASSWORD = env.str('COPERNICUS_PASSWORD','default password')
DOWNLOADS_DIRECTORY = env.str('DOWNLOADS_DIRECTORY', path.join(getcwd(), '.downloads'))