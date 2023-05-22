import DataLoader from './_data-loader.js'
import { execute, toPromise } from '@apollo/client'

const createArrayFromLength = l => {
  const arr = []
  for (let i = 0; i < l; i++) {
    arr.push(false)
  }
  return arr
}

export default ({ link, query }, interval) => {
  const logBatch = browserEvents =>
    new Promise(resolve => {
      toPromise(
        execute(link, {
          query,
          variables: {
            input: browserEvents,
          },
        })
      )
        .then(json => {
          if (json.errors) {
            console.log('logToGraphQl failed to catch error')
            json.errors.forEach((error, i) => {
              console.log(`error ${i + 1}:`, error)
            })
            return resolve(createArrayFromLength(browserEvents.length))
          }
          return resolve(json)
        })
        .catch(error => {
          /*steven: I don't think this catch can/always fires on error.
          If json is an object representing an error, resolve(json) fires.
          e.g. json === {errors: [{..., message:"Cannot ..."}], data: null}
          -mousemove logs are erroring with "Cannot destructure property 'EventLog' of '(intermediate value)' as it is undefined." at .then(resolve(json))*/
          console.error('logToGraphQL failed', error)
          return resolve(createArrayFromLength(browserEvents.length))
        })
    })

  const loader = new DataLoader(logBatch, interval)
  return browserEvent => loader.load(browserEvent)
}
