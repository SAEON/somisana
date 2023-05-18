import { db as mongoDb, collections, getDataFinders } from '../../mongo/index.js'

export default app => async (ctx, next) => {
  app.context.mongo = {
    db: mongoDb,
    collections,
    dataFinders: getDataFinders(), // Request level batching
  }

  await next()
}
