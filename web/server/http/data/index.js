import { pool } from '../../postgres/index.js'
import QueryStream from 'pg-query-stream'
import { stringify } from 'JSONStream'

export default async ctx => {
  const { model, time_step, run_date, depth } = ctx.query

  if (!model || !time_step || !run_date || !depth) {
    throw new Error(`Missing query params. Please specify model, time_step, run_date, depth values`)
  }

  ctx.compress = false
  const client = await pool.connect()

  await new Promise((resolve, reject) => {
    try {
      const query = new QueryStream(
        `with band as (
          select
            v.id,
            v.step_timestamp,
            round(v.depth::numeric, 0)::int2 depth,
            v.temperature,
            v.salinity,
            v.u,
            v.v,
            c.coord xy
          from values v
          join coordinates c on c.id = v.coordinateid  
        where
          v.modelid in ( select id from models where name = $1 )
          and v.time_step = $2
          and v.depth_level = $3
          and run_date = $4)
            
        select
        *
        from band;`,
        [model, time_step, depth, run_date],
        {
          batchSize: 100,
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
