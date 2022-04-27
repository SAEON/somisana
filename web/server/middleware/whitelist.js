export default (fn, ...whitelist) => async (ctx, next) => {
  for (const route of whitelist) {
    if (ctx.request.path.startsWith(route)) {
      return fn(ctx, next)
    }
  }

  return next()
}
