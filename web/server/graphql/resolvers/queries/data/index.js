import { pool } from '../../../../postgres/index.js'

export default async (_, { timeStep, runId, depth }, ctx) => {
  const client = await pool.connect()

  console.log({ timeStep, runId, depth })

  ctx.compress = true
  try {
    const res =
      depth === 0
        ? await client.query({
            text: `
              with _values as (
                select
                  v.id,
                  v.coordinateid,
                  v.depth_level,
                  v.temperature temp,
                  v.salinity salt,
                  v.u,
                  v.v,
                  v.depth,
                  0 target_depth
                from
                  public.values v
                where
                  v.runid = $1
                  and v.time_step = $2
                  and v.depth_level = ( select sigma_levels from models where id = ( select modelid from runs where id = $1 ) )
              ),
              interpolated_values as (
                select
                  v.coordinateid,
                  v.temp interpolated_temperature,
                  v.salt interpolated_salinity,
                  v.u interpolated_u,
                  v.v interpolated_v
                from
                  _values v
              ),
              grid as (
                select
                  st_x (c.pixel) px,
                  st_y (c.pixel) py,
                  c.latitude y,
                  c.longitude x,
                  v.interpolated_temperature,
                  v.interpolated_salinity,
                  v.interpolated_u,
                  v.interpolated_v
              from
                interpolated_values v
                right join coordinates c on c.id = v.coordinateid
                where
                  c.modelid = (
                    select
                      modelid
                    from
                      runs
                    where
                      id = $1))
              select
                x,
                y,
                g.interpolated_temperature
              from
                grid g
              order by
                py desc,
                px asc;`,
            values: [runId, timeStep],
            rowMode: 'array',
          })
        : await client.query({
            text: `
              select
                v.long x,
                v.lat y,
                v.interpolated_temperature::float
              from
                somisana_interpolate_values(
                  target_depth => $1,
                  runid => $2,
                  time_step => $3
                ) v`,
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
