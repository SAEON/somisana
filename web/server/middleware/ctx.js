import { db as mongoDb } from '../mongo/index.js'

export default app => async (ctx, next) => {
  app.context.mongo = {
    db: mongoDb,
  }

  await next()
}
