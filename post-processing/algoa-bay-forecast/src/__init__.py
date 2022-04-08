import ast
import matplotlib.pyplot as plt
import xarray as xr
import geojsoncontour
import numpy as np
from geojson import FeatureCollection
import cartopy.crs as ccrs
from datetime import timedelta, datetime
from pymongo import MongoClient
from environs import Env
import psycopg2
import os

# Using os to get enviromental variables (comment out for script to run, not sure variables are set)
#USERNAME = os.environ.get("USERNAME")
#PASSWORD = os.environ.get("PASSWORD")

# Using Env to get enviromental variables (comment out for script to run, not sure variables are set)
#env = Env()
#USERNAME = env('USERNAME')
#PASSWORD = env('PASSWORD')

#Connect to mongo
#client = MongoClient(username=USERNAME,
#                 password=PASSWORD)

#Conect to postgres
#conn = psycopg2.connect(
#    host="localhost",
#    database="",
#    user=USERNAME,
#    password=PASSWORD)

print("hello world. If you see this the dependencies installed correctly on deployment + test")
