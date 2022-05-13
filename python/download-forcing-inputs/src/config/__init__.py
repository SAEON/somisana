from environs import Env
env = Env()

COPERNICUS_USERNAME = env.str('COPERNICUS_USERNAME', 'Please specify in a .env file')
COPERNICUS_PASSWORD = env.str('COPERNICUS_PASSWORD', 'Please specify in a .env file')