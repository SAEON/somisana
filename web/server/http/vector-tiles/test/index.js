import { pool } from '../../../postgres/index.js'
import geojsonvt from 'geojson-vt'
// import vtpbf from 'vt-pbf'

export default async ctx => {
  const client = await pool.connect()
  // console.log(vtpbf)

  try {
    const result = await client.query(
      'select id, title, st_asgeojson(envelope) envelope from metadata;'
    )
    const geojson = result.rows[0].envelope
    const tileIndex = geojsonvt(JSON.parse(geojson))
    console.log(tileIndex)
    ctx.body = JSON.stringify(geojson)
  } catch (error) {
    console.log('error', error)
  } finally {
    client.release()
  }
}
