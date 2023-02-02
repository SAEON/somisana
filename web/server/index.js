import './lib/log-config.js'
import { createServer } from 'node:http'
import Koa from 'koa'
import KoaRouter from '@koa/router'
import zlib from 'node:zlib'
import koaBody from 'koa-bodyparser'
import koaCompress from 'koa-compress'
import dirname from './lib/dirname.js'
import { KEY, PORT } from './config/index.js'
import globalError from './middleware/error.js'
import restrictCors from './middleware/restrict-cors.js'
// import openCors from './middleware/open-cors.js'
import include from './middleware/include.js'
import exclude from './middleware/exclude.js'
import ssr from '../.ssr/index.js'
import graphql from './graphql/index.js'
import createRequestCtx from './middleware/ctx.js'
import testVectorTileRoute from './http/vector-tiles/test/index.js'
import { updateCoordinatesMask } from './postgres/index.js'

const __dirname = dirname(import.meta)

const api = new Koa()
api.keys = [KEY]
api.proxy = true

const compressionConfig = {
  flush: zlib.constants.Z_SYNC_FLUSH,
  level: 3,
}

// Configure middleware
api
  .use(globalError)
  .use(koaBody())
  .use(restrictCors)
  .use(
    include(
      koaCompress({
        filter: contentType => contentType.toLowerCase() === 'application/json',
        threshold: 2048,
        gzip: compressionConfig,
        deflate: compressionConfig,
        br: false,
      }),
      '/http',
      '/graphql'
    )
  )
  .use(createRequestCtx(api))
  .use(
    exclude(
      new KoaRouter()
        .get('/http', async ctx => (ctx.body = 'Welcome to the SOMISANA HTTP API'))
        .get('/http/tiles/test/:z/:x/:y.pbf', testVectorTileRoute)
        .get(/^.*$/, ssr)
        .routes(),
      '/graphql'
    )
  )

// Create the HTTP server
export const httpServer = createServer()

// Create the Apollo server
export const apolloServer = await graphql({ httpServer, api })

// Start the API
httpServer.on('request', api.callback()).listen(PORT, () => {
  console.info('=== SOMISANA READY ===')
})

try {
  await updateCoordinatesMask()
} catch (error) {
  console.error('Error updating coordinates mask on startup', error)
  process.exit(1)
}
