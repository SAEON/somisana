import pg from 'pg'
const { Pool } = pg

export default ({ host, user, database, password, port }) =>
  new Pool({
    host,
    user,
    database,
    password,
    port,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 10000,
  })
