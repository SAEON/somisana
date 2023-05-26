export default async (self, args, ctx) => {
  const { input, r = undefined } = args
  const { logToMongo, makeLog } = ctx.mongo

  logToMongo(
    ...input.map(log =>
      makeLog(ctx, {
        r,
        ...log,
      })
    )
  )
}
