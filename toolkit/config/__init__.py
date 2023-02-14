import os
import platform
from os.path import join
from environs import Env

env = Env()

homedir = os.path.expanduser("~")

PY_ENV = env.str("PY_ENV", "development")
CACHDIR = env.str(
    "CACHDIR",
    os.environ.get("CACHDIR")
    or (
        join(homedir, "Library", "Caches", "somisana")
        if platform.system() == "Darwin"
        else join(
            os.environ.get("LOCALAPPDATA") or join(homedir, "AppData", "Local"),
            "somisana-cache",
        )
        if platform.system() == "Windows"
        else join(
            os.environ.get("XDG_CACHE_HOME") or join(homedir, ".cache"), "somisana"
        )
    ),
)


PG_HOST = env.str("PG_HOST", "localhost")
PG_PORT = env.int("PG_PORT", 5432)
PG_DB = env.str("PG_DB", "somisana_local")
PG_USERNAME = env.str("PG_USERNAME", "admin")
PG_PASSWORD = env.str("PG_PASSWORD", "password")

MONGO_HOST = env.str("MONGO_HOST", "localhost:27017")
MONGO_DB = env.str("MONGO_DB", "somisana_local")
MONGO_USERNAME = env.str("MONGO_USERNAME", "admin")
MONGO_PASSWORD = env.str("MONGO_PASSWORD", "password")

COPERNICUS_USERNAME = env.str("COPERNICUS_USERNAME", "default username")
COPERNICUS_PASSWORD = env.str("COPERNICUS_PASSWORD", "default password")
