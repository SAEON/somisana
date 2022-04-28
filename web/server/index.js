import './lib/log-config.js'
import { createServer } from 'http'
import Koa from 'koa'
import KoaRouter from '@koa/router'
import zlib from 'zlib'
import koaBody from 'koa-bodyparser'
import koaCompress from 'koa-compress'
import dirname from './lib/dirname.js'
import { KEY, PORT } from './config/index.js'
import restrictCors from './middleware/restrict-cors.js'
import openCors from './middleware/open-cors.js'
import blacklist from './middleware/blacklist.js'
import whitelist from './middleware/whitelist.js'
import ssr from './ssr/index.js'
import graphql from './graphql/index.js'
import createRequestCtx from './middleware/ctx.js'

const __dirname = dirname(import.meta)

const api = new Koa()
api.keys = [KEY]
api.proxy = true

// Configure middleware
api
  .use(koaBody())
  .use(restrictCors)
  .use(
    whitelist(
      koaCompress({
        threshold: 2048,
        flush: zlib.constants.Z_SYNC_FLUSH,
      }),
      '/http',
      '/graphql'
    )
  ) // Only compress the /http and /graphql route responses
  .use(createRequestCtx(api))
  .use(
    blacklist(
      new KoaRouter()
        .get('/http', async ctx => (ctx.body = 'GET home route'))
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
