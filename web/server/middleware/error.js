export default async (ctx, next) => {
  try {
    await next()
  } catch (err) {
    err.status = err.statusCode || err.status || 500
    ctx.body = err.message
    ctx.app.emit('error', err, ctx)
  }
}
