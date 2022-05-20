export default async (self, args, ctx) => {
  const { findLocales } = ctx.mongo.dataFinders
  return await findLocales({})
}
