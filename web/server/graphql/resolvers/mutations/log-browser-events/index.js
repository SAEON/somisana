export default async (self, args, ctx) => {
  const { input, referrer = undefined } = args
  const { logToMongo, makeLog } = ctx.mongo

  logToMongo(
    ...input.map(log =>
      makeLog(ctx, {
        referrer,
        ...log,
      })
    )
  )
}
