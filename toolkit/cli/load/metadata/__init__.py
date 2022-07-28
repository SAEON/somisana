from postgis import connect


# Setup view that summarizes models
def create_view(model):
    with open('cli/load/metadata/metadata.sql', 'r') as file:
        sql = file.read()
        cursor = connect().cursor()
        cursor.execute(sql)