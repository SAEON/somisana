import {
  db as mongoDb,
  collections,
  getDataFinders,
  logToMongo,
  makeLog,
} from '../../mongo/index.js'
import gqlServer, { schema as gqlSchema } from '../../graphql/index.js'
import userModel from '../../user-model/index.js'
import { crypto } from '../../lib/index.js'
import { KEY } from '../../config/index.js'

const { encrypt, decrypt } = crypto

export default app => async (ctx, next) => {
  app.context.userInfo = ctx.state.user

  app.context.gql = {
    schema: gqlSchema,
    server: gqlServer,
  }

  app.context.mongo = {
    db: mongoDb,
    collections,
    dataFinders: getDataFinders(), // Request level batching
    logToMongo: logToMongo.load.bind(logToMongo),
    makeLog,
  }

  app.context.user = userModel

  app.context.crypto = {
    encrypt: plainTxt => encrypt(plainTxt, Buffer.from(KEY, 'base64')).toString('base64'),
    decrypt: encryptedTxt =>
      decrypt(Buffer.from(encryptedTxt, 'base64'), Buffer.from(KEY, 'base64')).toString('utf8'),
  }

  await next()
}
