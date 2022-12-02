import * as config from '../config/index.js'
const mask = str => str?.replace(/./g, '*').padEnd(60, '*')
const MASKED_FIELDS = config.DEPLOYMENT_ENV === 'production' ? ['KEY', 'MONGO_PASSWORD', 'PG_PASSWORD'] : []

console.info(
  'Server configuration',
  Object.fromEntries(
    Object.entries(config)
      .map(([field, value]) => [
        field,
        MASKED_FIELDS.includes(field)
          ? mask(value)
          : typeof value === 'function'
          ? value.toString()
          : value,
      ])
      .sort(([a], [b]) => {
        if (a > b) return 1
        if (b > a) return -1
        return 0
      })
  )
)
