export default app => async (ctx, next) => {
  await next()
}
