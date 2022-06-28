# from mongo import connection as mongoConnection
# from postgis import connection as pgConnection
from transform import transform

transform()

# # Test mongo connection
# mongoConnection['some-collection'].insert_one({"hello": "world"})
# print('Mongo working')

# # Test postgres connection
# cursor = pgConnection.cursor()
# cursor.execute("create table if not exists test (i int not null);")
# print('PG connection')

# print("If you don't see this message there was an error")
