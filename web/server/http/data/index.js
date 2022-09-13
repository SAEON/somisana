import { pool } from '../../postgres/index.js'
import QueryStream from 'pg-query-stream'
import { stringify } from 'JSONStream'

export default async ctx => {
  const { time_step = 120, runid = 1, depth = 0 } = ctx.query

  if (!time_step || !runid || !depth) {
    throw new Error(`Missing query params. Please specify time_step, runid, depth values`)
  }

  ctx.compress = false
  const client = await pool.connect()

  await new Promise((resolve, reject) => {
    try {
      const query = new QueryStream(
        `select
        st_x(st_transform( c.coord, 4326)) x,
        st_y(st_transform( c.coord, 4326)) y,
        v.interpolated_temperature::float
        from somisana_interpolate_values(
          target_depth => $1,
          runid => $2,
          time_step => $3
        ) v
        join coordinates c on c.id = v.coordinateid;`,
        [depth, runid, time_step],
        {
          batchSize: 100,
          rowMode: 'array',
        }
      )

      const stream = client.query(query)

      stream.on('error', reject)

      ctx.set('Content-type', 'application/json')
      ctx.set('Transfer-encoding', 'chunked')
      ctx.body = stream.pipe(stringify())
    } finally {
      client.release()
      resolve()
    }
  })
}
