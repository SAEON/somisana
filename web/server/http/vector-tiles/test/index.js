import { pool } from '../../../postgres/index.js'
import geojsonvt from 'geojson-vt'
import vtpbf from 'vt-pbf'

const client = await pool.connect()
let tileIndex

try {
  const result = await client.query(
    'select st_asgeojson(st_collect(st_transform(coord, 4326) )) geo from coordinates;'
  )
  const geojson = result.rows[0].geo

  tileIndex = geojsonvt(JSON.parse(geojson), {
    maxZoom: 24, // max zoom to preserve detail on; can't be higher than 24
    tolerance: 10, // simplification tolerance (higher means simpler)
    extent: 4096, // tile extent (both width and height)
    buffer: 64, // tile buffer on each side
    debug: 0, // logging level (0 to disable, 1 or 2)
    lineMetrics: false, // whether to enable line metrics tracking for LineString/MultiLineString features
    promoteId: null, // name of a feature property to promote to feature.id. Cannot be used with `generateId`
    generateId: false, // whether to generate feature ids. Cannot be used with `promoteId`
    indexMaxZoom: 5, // max zoom in the initial tile index
    indexMaxPoints: 10000, // max number of points per tile in the index
  })
} catch (error) {
  console.error(error)
} finally {
  client.release()
}

export default async ctx => {
  const z = parseInt(ctx.params.z, 10)
  const x = parseInt(ctx.params.x, 10)
  const y = parseInt(ctx.params.y, 10)

  const tile = tileIndex.getTile(z, x, y)

  if (!tile) {
    ctx.status = 204
    return
  }

  ctx.set('Content-Type', 'application/protobuf')
  ctx.body = Buffer.from(vtpbf.fromGeojsonVt({ testLayer: tile }, { version: 1, extent: 4096 }))
}
