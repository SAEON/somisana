import {
  PG_DB as database,
  PG_HOST as host,
  PG_PASSWORD as password,
  PG_USERNAME as user,
  PG_PORT as port,
} from '../config/index.js'
import createPool from './_pool.js'

export const pool = createPool({
  host,
  user,
  database,
  password,
  port,
})

export const updateCoordinatesMask = async () => {
  const client = await pool.connect()
  client.query(`
    with _coordinates as (
      select distinct
        c.id
      from
        public.coordinates c
      where
        c.has_value = false
        and exists (
          select
            1
          from
          values
          where
            coordinateid = c.id))
    update
      public.coordinates c
    set
      has_value = true
    where
      c.id in (
        select
          id
        from
          _coordinates);`)
}
