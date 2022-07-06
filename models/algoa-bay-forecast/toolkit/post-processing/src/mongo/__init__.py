# Connect to mongo
from pymongo import MongoClient
from config import MONGO_DB, MONGO_HOST, MONGO_USERNAME, MONGO_PASSWORD

connection = MongoClient(
    MONGO_HOST,
    username=MONGO_USERNAME,
    password=MONGO_PASSWORD
)[MONGO_DB]

# Example usage
# from mongo import connection as mongoConnection
# mongoConnection['some-collection'].insert_one({"hello": "world"})
# print('Mongo working')
