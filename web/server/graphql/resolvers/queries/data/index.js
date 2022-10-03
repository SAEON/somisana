import { pool } from '../../../../postgres/index.js'

export default async (_, { timeStep, runId, depth }, ctx) => {
  const client = await pool.connect()

  ctx.compress = true
  try {
    const res =
      depth === 0
        ? await client.query({
            text: `
    
    `,
            values: [runId, timeStep],
            rowMode: 'array',
          })
        : await client.query({
            text: `
        select
          st_x(st_transform( c.coord, 4326)) x,
          st_y(st_transform( c.coord, 4326)) y,
          v.interpolated_temperature::float
        from
          somisana_interpolate_values(
            target_depth => $1,
            runid => $2,
            time_step => $3
          ) v
        join
          coordinates c on c.id = v.coordinateid;`,
            values: [depth, runId, timeStep],
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
