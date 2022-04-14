import { ALLOWED_ORIGINS } from '../config/index.js'

export default async (ctx, next) => {
  const { method, headers } = ctx.req
  const { origin } = headers
  if (ALLOWED_ORIGINS.includes(origin)) {
    ctx.set('Access-Control-Allow-Origin', origin)
  }
  ctx.set('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
  ctx.set(
    'Access-Control-Allow-Headers',
    'Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers, credentials, Authorization'
  )
  ctx.set('Access-Control-Allow-Credentials', true)
  if (method === 'OPTIONS') {
    ctx.status = 200
  } else {
    await next()
  }
}
