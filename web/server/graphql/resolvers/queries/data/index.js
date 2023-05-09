import { pool } from '../../../../postgres/index.js'

export default async (_, { timeStep, runId, depth }, ctx) => {
  const client = await pool.connect()
  try {
    const res = await client.query({
      text: `
        select
          coordinateid,
          x,
          y,
          temperature,
          salinity,
          u,
          v,
          depth
        from
        public.interpolated_values
        where
          runid = $1
          and time_step = $2
          and depth = $3;`,
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
