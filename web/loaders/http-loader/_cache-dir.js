import path from 'path'
import { homedir } from 'os'

export const HTTP_IMPORT_CACHING = process.env.HTTP_IMPORT_CACHING || 'default'

const allowedStrategies = [
  'default',
  'no-store',
  'reload',
  'no-cache',
  'force-cache',
  'only-if-cached',
]

if (!allowedStrategies.includes(HTTP_IMPORT_CACHING)) {
  throw new Error(
    `Incorrect HTTP_IMPORT_CACHING value "${HTTP_IMPORT_CACHING}". Please refer to make-fetch-happen documentation https://github.com/npm/make-fetch-happen#--optscache for allowed values`
  )
}

export const HTTP_IMPORT_CACHDIR =
  process.env.HTTP_IMPORT_CACHDIR ||
  (process.platform === 'darwin'
    ? path.join(homedir(), 'Library', 'Caches', 'node-loader-http')
    : process.platform === 'win32'
    ? path.join(
        process.env.LOCALAPPDATA || path.join(homedir(), 'AppData', 'Local'),
        'node-loader-http-cache'
      )
    : path.join(process.env.XDG_CACHE_HOME || path.join(homedir(), '.cache'), 'node-loader-http'))

console.info('@node-loader/http', 'cache =', HTTP_IMPORT_CACHING)
console.info('@node-loader/http', 'cachePath =', HTTP_IMPORT_CACHDIR)
