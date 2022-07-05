# from mongo import connection as mongoConnection
# from postgis import connection as pgConnection

# # Test mongo connection
# mongoConnection['some-collection'].insert_one({"hello": "world"})
# print('Mongo working')

# # Test postgres connection
# cursor = pgConnection.cursor()
# cursor.execute("create table if not exists test (i int not null);")
# print('PG connection')

def load(options, arguments):
  nc_input_path = options.nc_input_path
  print('nc-input-path', nc_input_path)