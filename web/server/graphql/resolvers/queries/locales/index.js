import { ObjectId } from 'mongodb'

export default async (self, { id, languages }, ctx) => {
  const { findLocales } = ctx.mongo.dataFinders

  const query = {}
  if (id) query._id = ObjectId(id)
  else if (languages) query.language = { $in: languages }

  return await findLocales(query)
}
