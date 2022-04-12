import ast
import matplotlib.pyplot as plt
import xarray as xr
import geojsoncontour
import numpy as np
from geojson import FeatureCollection
import cartopy.crs as ccrs
from datetime import timedelta, datetime
from pymongo import MongoClient
import config
import psycopg2

# Connect to mongo
mongo = MongoClient(
          config.MONGO_HOST,
          username=config.MONGO_USERNAME,
          password=config.MONGO_PASSWORD
        )[config.MONGO_DB]

# Test mongo insert
mongo['some-collection'].insert_one({"hello": "world"})

print('Mongo client is connecting correctly')

#Conect to postgres
pg = psycopg2.connect(
          host=config.PG_HOST,
          port=config.PG_PORT,
          database=config.PG_DB,
          user=config.PG_USERNAME,
          password=config.PG_PASSWORD
        )

pg.autocommit = True

cursor = pg.cursor()
cursor.execute("create table if not exists test (i int not null);")

print('PG client is connecting correctly')

print("If you don't see this message there was an error")
