from psycopg_pool.pool import ConnectionPool
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME

pool = ConnectionPool(
    conninfo="""
        dbname={0}
        user={1}
        port={2}
        host={3}
        password={4}""".format(
        str(PG_DB), str(PG_USERNAME), str(PG_PORT), str(PG_HOST), str(PG_PASSWORD)
    ),
    open=True,
)


CREATE_SQL_PATH = "postgis/schema.sql"
DROP_SQL_PATH = "postgis/drop-schema.sql"

def exe_file(path):
    with open(path, "r") as file:
        sql = file.read()
        with pool.connection(timeout = 60) as client:
            client.execute(sql)

def setup():
    print(
        "\n*************************************\n(Re)creating the SOMISANA database!!!\n*************************************\n"
    )
    exe_file(CREATE_SQL_PATH)


def drop():
    print(
        "\n*************************************\nDropping the SOMISANA the database!!!\n*************************************\n"
    )
    exe_file(DROP_SQL_PATH)
