from environs import Env
env = Env()

COPERNICUS_USERNAME = env.str('COPERNICUS_USERNAME','default username')
COPERNICUS_PASSWORD = env.str('COPERNICUS_PASSWORD','default password')
