import { pool } from '../../../../postgres/index.js'

export default async (self, { id = undefined }, ctx) => {
  const client = await pool.connect()

  try {
    const models = (
      await client.query(`
        select
          id,
          name,
          min_x,
          min_y,
          max_x,
          max_y,
          st_asgeojson(convexhull) convexhull,
          st_asgeojson(envelope) envelope,
          'Model' "_gqlType"
        from metadata;`)
    ).rows

    return id ? [models.find(({ id: _id }) => _id == id)].filter(_ => _) : models
  } finally {
    client.release()
  }
}
