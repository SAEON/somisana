import { pool } from '../../../../postgres/index.js'

export default async (self, { id = undefined }, ctx) => {
  const client = await pool.connect()

  try {
    const models = (
      await client.query(`
        select 
          m.id, 
          m.name, 
          m.title, 
          m.description, 
          m.creator, 
          m.creator_contact_email, 
          m.type, 
          m.min_x, 
          m.min_y, 
          m.max_x, 
          m.max_y, 
          m.grid_width, 
          m.grid_height, 
          st_asgeojson(m.convexhull) convexhull, 
          st_asgeojson(m.envelope) envelope,
          ( select 
              json_agg(t_runs) 
            from 
              (
                select 
                  * 
                from 
                  runs 
                where 
                  runs.modelid = m.id 
                  and runs.successful = true 
                order by 
                  runs.run_date desc 
                limit 
                  10
              ) t_runs
          ) runs 
      from 
        models m;`)
    ).rows

    return id ? [models.find(({ id: _id }) => _id == id)].filter(_ => _) : models
  } finally {
    client.release()
  }
}
