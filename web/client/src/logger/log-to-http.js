import DataLoader from './_data-loader.js'

export default (uri, client = fetch, opts = {}, interval) => {
  const logBatch = msgs =>
    new Promise((resolve, reject) => {
      client(
        uri,
        Object.assign(
          {
            mode: 'cors',
            headers: {
              Accept: 'application/json',
              'Content-Type': 'application/json',
            },
            method: 'POST',
            body: JSON.stringify(msgs),
          },
          opts
        )
      )
        .then(res => res.text())
        .then(json => resolve(json))
        .catch(error => reject(error))
    })

  const loader = new DataLoader(logBatch, interval)
  return msg => loader.load(msg)
}
