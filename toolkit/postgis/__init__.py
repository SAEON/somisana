from psycopg2.pool import ThreadedConnectionPool
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME

_pool_ = None

CREATE_SQL_PATH = "postgis/schema.sql"
DROP_SQL_PATH = "postgis/drop-schema.sql"


def exe_sql_file(path):
    with open(path, "r") as file:
        sql = file.read()
        client = connect()
        cursor = client.cursor()
        cursor.execute(sql)
        release(client)


def connect():
    global _pool_
    if not _pool_:
        _pool_ = ThreadedConnectionPool(
            1,
            20,
            host=PG_HOST,
            port=PG_PORT,
            database=PG_DB,
            user=PG_USERNAME,
            password=PG_PASSWORD,
        )
    client = _pool_.getconn()
    client.autocommit = True
    if client:
        return client
    else:
        raise Exception(
            "Unknown error occurred checking out a client from the postgis connection pool"
        )


def release(client):
    if not _pool_:
        raise Exception("The connection pool has not been created yet")
    else:
        _pool_.putconn(client)


def setup():
    print(
        "\n*************************************\n(Re)creating the SOMISANA database!!!\n*************************************\n"
    )
    exe_sql_file(CREATE_SQL_PATH)


def drop():
    print(
        "\n*************************************\nDropping the SOMISANA the database!!!\n*************************************\n"
    )
    exe_sql_file(DROP_SQL_PATH)
