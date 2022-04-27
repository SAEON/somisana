import './lib/log-config.js'
import { createServer } from 'http'
import Koa from 'koa'
import KoaRouter from '@koa/router'
import dirname from './lib/dirname.js'
import { KEY, PORT } from './config/index.js'
import restrictCors from './middleware/restrict-cors.js'
import openCors from './middleware/open-cors.js'
import blacklist from './middleware/blacklist.js'
import whitelist from './middleware/whitelist.js'
import ssr from './ssr/index.js'
import apolloServer from './graphql/index.js'

const __dirname = dirname(import.meta)

const api = new Koa()
api.keys = [KEY]
api.proxy = true

api
  .use(blacklist(restrictCors, '/'))
  .use(whitelist(openCors, '/'))
  .use(
    blacklist(
      new KoaRouter()
        .get('/http', async ctx => (ctx.body = 'GET home route'))
        .get(/^.*$/, ssr)
        .routes(),
      '/graphql'
    )
  )

// Configure HTTP servers
const httpServer = createServer(api.callback())

// Configure Apollo servers
apolloServer
  .start()
  .then(() => apolloServer.applyMiddleware({ app: api, cors: false }))
  .then(() => console.log('gql'))

httpServer.listen(PORT, () => {
  console.info('=== SOMISANA READY ===')
})
