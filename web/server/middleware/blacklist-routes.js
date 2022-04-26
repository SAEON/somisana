export default (fn, ...blacklist) =>
  async (ctx, next) => {
    for (const route of blacklist) {
      if (ctx.request.path.startsWith(route)) {
        return next()
      }
    }

    return fn(ctx, next)
  }
