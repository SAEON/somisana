import { pool } from '../../postgres/index.js'
import QueryStream from 'pg-query-stream'
import { stringify } from 'JSONStream'

export default async ctx => {
  const { model = 1, time_step = 120, runid = 1, depth = 0 } = ctx.query

  // if (!model || !time_step || !run_date || !depth) {
  //   throw new Error(`Missing query params. Please specify model, time_step, run_date, depth values`)
  // }

  ctx.compress = false
  const client = await pool.connect()

  await new Promise((resolve, reject) => {
    try {
      const query = new QueryStream(
        `select
          st_x(c.coord) x,
          st_y(c.coord) y,
          v.interpolated_temperature::float
          from somisana_interpolate_values(
            target_depth => 0,
            runid => 1,
            time_step => 120,
            modelid => 1
          ) v
          join coordinates c on c.id = v.coordinateid;`,
        [],
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
