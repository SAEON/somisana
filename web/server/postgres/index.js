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
  const a = performance.now()

  try {
    await client.query(`
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
  } catch (error) {
    console.error('Error updating coordinate land masking', error)
    throw error
  } finally {
    client.release()
    const b = performance.now()
    console.info('Refreshed coordinate land masking', ((b - a) / 1000).toFixed(2), 'seconds')
  }
}
