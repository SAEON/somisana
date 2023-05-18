import { MongoClient } from 'mongodb'
import {
  MONGO_DB as DB,
  MONGO_HOST,
  MONGO_USERNAME as username,
  MONGO_PASSWORD as password,
  NODE_ENV,
} from '../config/index.js'
import makeDataFinders from './data-finders/index.js'
import _collections from './collections/index.js'
import insertLocales from './locales/index.js'
import _Logger from './_logger.js'
export { makeLog } from './_logger.js'

export const db = new MongoClient(MONGO_HOST, {
  auth: {
    username,
    password,
  },
  authMechanism: 'SCRAM-SHA-256',
})
  .connect()
  .then(client => client.db(DB))
  .catch(error => {
    console.error('Unable to connect to MongoDB', error)

    /**
     * Allow local development without Mongo
     * Useful for changes to the React clients
     */
    if (NODE_ENV === 'production') process.exit(1)
  })

export const collections = Object.entries(_collections)
  .reduce(async (accumulator, [alias, { name }]) => {
    const _accumulator = await accumulator
    _accumulator[alias] = (await db).collection(name)
    return _accumulator
  }, Promise.resolve({}))
  .catch(error => console.error('Unable to load MongoDB collections', error))

export const getDataFinders = makeDataFinders(db)

/**
 * ================================================
 * Configure MongoDB on API startup
 * ================================================
 */

// Create collections
;(async () => {
  const _db = await db

  await Promise.all(
    Object.entries(_collections).map(([, { name, validator = {} }]) =>
      _db.createCollection(name, { validator }).catch(error => {
        if (error.code == 48) {
          console.info(`Collection already exists`, name)
        } else {
          console.error(error)
          process.exit(1)
        }
      })
    )
  )

  /**
   * Apply indices
   *
   * Error code 85 represents an index that
   * needs to be rebuilt (the definition was
   * changed in the source code).
   *
   * NOTE - Don't change indices directly in
   * MongoDB!!
   */
  await Promise.all(
    Object.entries(_collections)
      .map(([, { name, indices = [] }]) => {
        return Promise.all(
          indices.map(async ({ index, options }) => {
            console.info('Applying index', index, 'to collection', name, options)
            return _db
              .collection(name)
              .createIndex(index, options)
              .catch(async error => {
                if (error.code === 85) {
                  console.info('Recreating index on', name, ':: Index name:', index)
                  try {
                    console.log(index)
                    await _db.collection(name).dropIndex(`${index}_1`)
                    await _db.collection(name).createIndex(index, options)
                  } catch (error) {
                    throw new Error(`Unable to recreate index. ${error.message}`)
                  }
                } else {
                  throw error
                }
              })
          })
        )
      })
      .flat()
  )

  await insertLocales(_db)

  console.info('MongoDB configured')
})().catch(error => {
  console.error('Error seeding MongoDB', error.message)
  process.exit(1)
})

/**
 * Application-level batching for inserting UI logs
 * to MongoDB.
 */
const Logger = _Logger(collections)
export const logToMongo = new Logger()
