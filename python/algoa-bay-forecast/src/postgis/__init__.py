import psycopg2
from config import PG_DB, PG_HOST, PG_PASSWORD, PG_PORT, PG_USERNAME

# Connect to postgres
connection = psycopg2.connect(
    host=PG_HOST,
    port=PG_PORT,
    database=PG_DB,
    user=PG_USERNAME,
    password=PG_PASSWORD
)

# Load ./schema.sql
# Apply schema.sql to the postgis server


connection.autocommit = True