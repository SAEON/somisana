import './lib/log-config.js'
import { createServer } from 'http'
import Koa from 'koa'
import KoaRouter from '@koa/router'
import koaCompress from 'koa-compress'
import zlib from 'zlib'
import dirname from './lib/dirname.js'
import { KEY, PORT } from './config/index.js'
import restrictCors from './middleware/restrict-cors.js'
import openCors from './middleware/open-cors.js'
import blacklistRoutes from './middleware/blacklist-routes.js'
import whitelistRoutes from './middleware/whitelist-routes.js'
import ssr from './ssr/index.js'

const __dirname = dirname(import.meta)

const api = new Koa()
api.keys = [KEY]
api.proxy = true

api
  .use(
    blacklistRoutes(
      koaCompress({
        threshold: 2048,
        flush: zlib.constants.Z_SYNC_FLUSH,
      }),
      '/'
    )
  )
  .use(blacklistRoutes(restrictCors, '/'))
  .use(whitelistRoutes(openCors, '/'))
  .use(new KoaRouter().get(/^.*$/, ssr).routes())

// Configure HTTP servers
const httpServer = createServer(api.callback())

httpServer.listen(PORT, () => {
  console.info('=== SOMISANA READY ===')
})
