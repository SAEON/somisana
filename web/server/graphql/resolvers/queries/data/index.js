import { pool } from '../../../../postgres/index.js'

export default async (_, { timeStep, runId, depth }, ctx) => {
  const client = await pool.connect()
  try {
    const res = await client.query({
      text: `
        select
          v.coordinateid,
          v.x,
          v.y,
          v.temperature,
          v.salinity,
          v.u,
          v.v,
          v.depth,
          st_x (c.pixel) px,
          st_y (c.pixel) py
        from
          public.interpolated_values v
          right join coordinates c on c.id = v.coordinateid
        where
          runid = $1
          and time_step = $2
          and depth = $3
        order by
          py desc,
          px asc;`,
      values: [runId, timeStep, depth],
      rowMode: 'array',
    })

    return {
      id: `${timeStep}${runId}${depth}`,
      json: res.rows,
    }
  } catch (error) {
    console.error('Error', error)
    throw error
  } finally {
    client.release()
  }
}
