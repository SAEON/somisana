import { KEY, PORT, PASSPORT_SSO_MAXAGE_HOURS } from './config/index.js'
import { createServer } from 'node:http'
import Koa from 'koa'
import KoaRouter from '@koa/router'
import zlib from 'node:zlib'
import koaBody from 'koa-bodyparser'
import koaCompress from 'koa-compress'
import koaSession from 'koa-session'
import koaPassport from 'koa-passport'
import { hoursToMilliseconds } from './lib/index.js'
import configureApolloGQLServer from './graphql/index.js'
import './passport/index.js'
import {
  clientSession,
  ctx as createRequestCtx,
  exclude,
  include,
  restrictCors,
  error as globalError,
} from './middleware/index.js'
import {
  authenticate as authenticateRoute,
  loginSuccess as loginSuccessRoute,
  clientInfo as clientInfoRoute,
  login as loginRoute,
  logout as logoutRoute,
  home as homeRoute,
  oauthAuthenticationCallback as oauthAuthenticationCallbackRoute,
} from './http/index.js'

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
  .use(koaBody())
  .use(async (ctx, next) => {
    const protocol = ctx.protocol
    const isHttp = protocol === 'http'
    return koaSession(
      {
        key: 'somisana.koa.sess',
        maxAge: hoursToMilliseconds(PASSPORT_SSO_MAXAGE_HOURS),
        autoCommit: true,
        overwrite: true,
        httpOnly: true,
        signed: true,
        rolling: true,
        renew: true,
        secure: isHttp ? false : true,
        sameSite: isHttp ? 'lax' : 'none',
      },
      api
    )(ctx, next)
  })
  .use(restrictCors)
  .use(clientSession)
  .use(koaPassport.initialize())
  .use(koaPassport.session())
  .use(createRequestCtx(api))
  .use(
    exclude(
      new KoaRouter()
        .get('/http', homeRoute)
        .get('/http/client-info', clientInfoRoute)
        .get('/http/authenticate/redirect', oauthAuthenticationCallbackRoute, loginSuccessRoute) // passport
        .get('/http/login', loginRoute) // passport
        .get('/http/authenticate', authenticateRoute)
        .get('/http/logout', logoutRoute)
        .get(/^.*$/, async req => (req.body = 'Welcome to the SOMISANA API'))
        .routes(),
      '/graphql'
    )
  )

// Create the HTTP server
export const httpServer = createServer()

// Configure Apollo server
await configureApolloGQLServer({ httpServer, api })
console.info('Apollo server configured')

// Start the API
httpServer.on('request', api.callback()).listen(PORT, () => {
  console.info('=== SOMISANA READY ===')
})
