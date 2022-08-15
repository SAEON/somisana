import {
  PG_DB as database,
  PG_HOST as host,
  PG_PASSWORD as password,
  PG_USERNAME as user,
  PG_PORT as port,
} from '../config/index.js'
import createPool from './_pool.js'

export const simplePool = createPool({
  host,
  user,
  database,
  password,
  port,
})
