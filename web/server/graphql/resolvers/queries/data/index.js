import { pool } from '../../../../postgres/index.js'

export default async (_, { timeStep, runId, depth }, ctx) => {
  const client = await pool.connect()
  let res
  try {
    switch (depth) {
      case -99999:
        res = await client.query({
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
                v.depth
              from
                public.values v
              where
                v.runid = $1
                and v.time_step = $2
                and v.depth_level = 1
            ),
            interpolated_values as (
              select
                v.coordinateid,
                v.temp interpolated_temperature,
                v.salt interpolated_salinity,
                v.u interpolated_u,
                v.v interpolated_v,
                v.depth
              from
                _values v
            ),
            grid as (
              select
                c.id coordinateid,
                st_x (c.pixel) px,
                st_y (c.pixel) py,
                c.latitude y,
                c.longitude x,
                v.interpolated_temperature,
                v.interpolated_salinity,
                v.interpolated_u,
                v.interpolated_v,
                v.depth
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
              g.coordinateid,
              x,
              y,
              g.interpolated_temperature,
              g.interpolated_salinity,
              g.interpolated_u,
              g.interpolated_v,
              g.depth
            from
              grid g
            order by
              py desc,
              px asc;`,
          values: [runId, timeStep],
          rowMode: 'array',
        })
        break
      case 0:
        res = await client.query({
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
                v.depth
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
                v.v interpolated_v,
                v.depth
              from
                _values v
            ),
            grid as (
              select
                c.id coordinateid,
                st_x (c.pixel) px,
                st_y (c.pixel) py,
                c.latitude y,
                c.longitude x,
                v.interpolated_temperature,
                v.interpolated_salinity,
                v.interpolated_u,
                v.interpolated_v,
                v.depth
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
              g.coordinateid,
              x,
              y,
              g.interpolated_temperature,
              g.interpolated_salinity,
              g.interpolated_u,
              g.interpolated_v,
              g.depth
            from
              grid g
            order by
              py desc,
              px asc;`,
          values: [runId, timeStep],
          rowMode: 'array',
        })
        break
      default:
        res = await client.query({
          text: `
            with _values as (
              select
                v.coordinateid,
                v.x,
                v.y,
                v.temperature,
                v.salinity,
                v.u,
                v.v,
                v.depth
              from
                public.interpolated_values v
              where
                runid = $1
                and time_step = $2
                and depth = $3
                and temperature is not null
            ),
            grid as (
              select
                c.id coordinateid,
                st_x (c.pixel) px,
                st_y (c.pixel) py,
                c.latitude y,
                c.longitude x,
                v.temperature,
                v.salinity,
                v.u,
                v.v,
                v.depth
              from _values v
              right join coordinates c on c.id = v.coordinateid
              where
                c.modelid = (
                  select
                    modelid
                  from
                    runs
                  where
                    id = 61))
              select
                g.coordinateid,
                x,
                y,
                g.temperature,
                g.salinity,
                g.u,
                g.v,
                g.depth
              from
                grid g
              order by
                py desc,
                px asc;`,
          values: [runId, timeStep, depth],
          rowMode: 'array',
        })
        break
    }

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
