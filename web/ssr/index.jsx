import { join, normalize } from 'path'
import fs from 'fs/promises'
import dirname from '../server/lib/dirname.js'
import { createReadStream } from 'fs'
import { createEmotionCache } from '../common/app'
import createEmotionServer from '@emotion/server/create-instance'
import Layout from './_layout.jsx'

/**
 * Emotion doesn't support stream-rendering yet
 * Once it does, please update
 */
import { renderToString } from 'react-dom/server'

const INDEX_NAME = 'somisana'
const __dirname = dirname(import.meta)
const files = normalize(join(__dirname, '../.client'))
const APP_ENTRIES = await fs
  .readdir(normalize(join(__dirname, '../client/html')))
  .then(files => files.filter(f => f.includes('.html')))
  .then(files => files.map(f => f.replace('.html', '')))

const rewrite = str =>
  str.replace(/(explore)\/(.*)/, (match, g1, g2) => {
    if (str.endsWith('.js')) {
      return str.replace(`${g1}/`, '')
    }
    return match.replace(`${g1}/`, 'esri-atlas').replace(g2, '')
  })

export default async ctx => {
  const url = rewrite(ctx.request.url)

  if (url.endsWith('.txt')) {
    ctx.set('Content-type', 'text/plain')
    ctx.body = createReadStream(normalize(join(files, url)))
  } else if (url.endsWith('.ico')) {
    ctx.set('Content-type', 'image/x-icon')
    ctx.body = createReadStream(normalize(join(files, url)))
  } else if (url.endsWith('.js')) {
    ctx.set('Content-type', 'application/javascript; charset=utf-8')
    ctx.body = createReadStream(normalize(join(files, url)))
  } else if (url.endsWith('.png')) {
    ctx.set('Content-type', 'image/png')
    ctx.body = createReadStream(normalize(join(files, url)))
  } else if (url.endsWith('.css')) {
    ctx.set('Content-type', 'text/css')
    ctx.body = createReadStream(normalize(join(files, url)))
  } else if (url.endsWith('site.webmanifest')) {
    ctx.set('Content-type', 'application/json; charset=utf-8')
    ctx.body = createReadStream(normalize(join(files, url)))
  } else {
    ctx.set('Content-type', 'text/html')
    const entry = ctx.request.url.replace('.html', '').replace('/', '')
    const page = entry ? (APP_ENTRIES.includes(entry) ? entry : INDEX_NAME) : INDEX_NAME

    const htmlUtf8 = await fs.readFile(normalize(join(files, `${page}.html`)), {
      encoding: 'utf-8',
    })
    const SsrEntry = await import(normalize(join(files, `ssr.${page}.js`))).then(
      ({ default: C }) => C
    )

    const emotionCache = createEmotionCache()
    const { extractCriticalToChunks, constructStyleTagsFromChunks } =
      createEmotionServer(emotionCache)

    const html = renderToString(
      <Layout ctx={ctx} emotionCache={emotionCache}>
        <SsrEntry />
      </Layout>
    )

    const emotionChunks = extractCriticalToChunks(html)
    const emotionCss = constructStyleTagsFromChunks(emotionChunks)

    const result = htmlUtf8
      .replace('</title>', `</title>${emotionCss}`)
      .replace('<div id="root"></div>', `<div id="root">${html}</div>`)

    ctx.body = result
  }
}
