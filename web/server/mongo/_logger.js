import { PASSPORT_SSO_SESSION_ID } from '../config/index.js'
import { MongoClient } from 'mongodb'
import DataLoader from 'dataloader'
import { ObjectId } from 'mongodb'

export const IP_RESOLVER_API_ADDRESS = 'http://ip-api.com/batch'

export const LOG_FIELDS =
  'status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon,timezone,offset,currency,isp,org,as,asname,mobile,proxy,hosting,query'

/**
 * Application level batching of requests for
 * ip -> location resolution using the API at
 * https://ip-api.com/docs/api:batch
 *
 * keys: [ip1, ip2, etc]
 */
const resolveIpBatch = async keys => {
  const res = await fetch(IP_RESOLVER_API_ADDRESS, {
    method: 'POST',
    body: JSON.stringify(
      [...new Set(keys)].map(query => ({
        query,
        fields: LOG_FIELDS,
        lang: 'en',
      }))
    ),
    headers: {
      'Content-type': 'application/json',
    },
  })

  const xTtl = res.headers.get('X-Ttl')
  const xRl = res.headers.get('X-Rl')

  if (xRl < 2) {
    throw new Error(
      `Usage limit of the ${IP_RESOLVER_API_ADDRESS} endpoint (15 requests per minute). Please wait ${xTtl} seconds before requesting IP location Information again`
    )
  }

  const json = await res.json()
  return keys.map(ipAddress => json.find(({ query }) => query === ipAddress))
}

const locationFinder = new DataLoader(ipAddresses => resolveIpBatch(ipAddresses), {
  maxBatchSize: 100,
})

export const makeLog = async (ctx, otherFields) => {
  const ipAddress = ctx?.request.headers['X-Real-IP'] || ctx?.request.ip || 'UNKNOWN'

  const ipInfo =
    (await locationFinder.load(ipAddress).catch(error => {
      console.error('Error resolving log IP address to location', error.message)
      return {}
    })) || {}

  const { countryCode, city, district } = ipInfo

  const ipLocation =
    countryCode && city ? `${countryCode}/${city}${district ? `/${district}` : ''}` : 'UNKNOWN'

  return {
    userId: ctx?.user.info(ctx)?.id ? new ObjectId(ctx.user.info(ctx)?.id) : undefined,
    createdAt: new Date(), // This should be overridden by client logs, otherwise createdAt values won't be accurate
    clientSession: ctx?.cookies.get(PASSPORT_SSO_SESSION_ID) || 'no-session', // This can happen if user blocks cookies in their browser
    clientInfo: {
      ipAddress,
      ipLocation,
      userAgent: ctx?.request.headers['user-agent'] || 'UNKNOWN',
      ipInfo: { ...ipInfo, _source: IP_RESOLVER_API_ADDRESS },
    },
    ...otherFields,
  }
}

const BATCH_SIZE = 1000

export default collections => {
  return class LogBatcher {
    constructor() {
      this._queue = []
    }

    async load(...logs) {
      const resolvedQueries = await Promise.all(logs)
      this._queue.push(...resolvedQueries)
      this.processQueue()
    }

    async processQueue() {
      if (!this._queue.length) {
        return
      }

      /**
       * Pushing this to the end of the event loop
       * is probably unnecessary, but can potentially
       * reduce the number of database trips
       */
      setImmediate(async () => {
        const batch = this._queue.slice(0, BATCH_SIZE)
        this._queue = this._queue.slice(BATCH_SIZE)
        await this.insertBatch(batch)
      })
    }

    async insertBatch(batch) {
      try {
        const { Logs } = await collections
        const { insertedCount } = await Logs.insertMany(batch)
        console.info('Client events logged', insertedCount)
      } catch (error) {
        this.handleError(error, batch)
      } finally {
        this.processQueue()
      }
    }

    handleError(error, batch) {
      if (error instanceof MongoClient.MongoError && error.name === 'BulkWriteError') {
        const validationError = error.result.writeErrors[0].err
        console.error(
          'Error logging client events to Mongo. (validation error)',
          validationError,
          JSON.stringify(batch, null, 2)
        )
      } else {
        console.error(
          'Error logging client events to Mongo (ignore this unless very frequent).',
          error,
          JSON.stringify(batch, null, 2)
        )
      }
    }
  }
}

