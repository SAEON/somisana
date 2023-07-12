export default async ctx => {
  const ipAddress = ctx.request.headers['X-Real-IP'] || ctx.request.ip
  const userAgent = ctx.request.headers['user-agent']

  ctx.body = {
    ipAddress,
    userAgent,
  }
}
