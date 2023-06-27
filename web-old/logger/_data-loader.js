/**
 * Inspired by the dataloader library
 * https://www.npmjs.com/package/dataloader
 *
 * The dataloader library is actually cross-platform,
 * in that it will run in a browser or on the server.
 *
 * However batching GraphQL or HTTP requests that are
 * configured at runtime, it becomes a bit more difficult
 * to validate that the return of the batching function is
 * a Promised array of the same length as the input of values.
 * Also, this would dictate the design of HTTP and GraphQL
 * endpoints for projects in which this library is used.
 *
 * For these reasons, the dataloader library is NOT
 * used despite that it is certainly a better
 * implementation of this type of batching function.
 */

export default class {
  constructor(_batchLoadingFn, _interval = 2000) {
    this._timer
    this._keys = []
    this._batchLoadingFn = _batchLoadingFn
    this._interval = _interval
  }

  load(key) {
    clearTimeout(this._timer)
    const promisedValue = new Promise(resolve => this._keys.push({ key, resolve }))
    this._timer = setTimeout(() => {
      try {
        this._batchLoadingFn(this._keys.map(k => k.key)).then(values => {
          this._keys.forEach(({ resolve }, i) => {
            resolve(values[i])
          })
          this._keys = []
        })
      } catch (error) {
        console.warn(`Unable to log to remote server`, error)
        this._keys = []
      }
    }, this._interval)
    return promisedValue
  }
}
