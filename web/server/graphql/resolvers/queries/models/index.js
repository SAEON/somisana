import { pool } from '../../../../postgres/index.js'

export default async (self, { id = undefined }, ctx) => {
  const client = await pool.connect()

  try {
    const models = (
      await client.query(`
        select
          id,
          name,
          title,
          description,
          creator,
          creator_contact_email,
          type,
          min_x,
          min_y,
          max_x,
          max_y,
          grid_width,
          grid_height,
          st_asgeojson(convexhull) convexhull,
          st_asgeojson(envelope) envelope,
          runs,
          'Model' "_gqlType"
        from metadata;`)
    ).rows

    return id ? [models.find(({ id: _id }) => _id == id)].filter(_ => _) : models
  } finally {
    client.release()
  }
}
