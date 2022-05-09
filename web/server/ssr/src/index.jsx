import { renderToString } from 'react-dom/server'
import { join } from 'path'
import fs from 'fs/promises'
import dirname from '../../lib/dirname.js'
import { createReadStream } from 'fs'
import { createEmotionCache } from '../../../common/app'
import emotionServer from '@emotion/server/create-instance'

import Layout from './_layout.jsx'

const { default: createEmotionServer } = emotionServer

const __dirname = dirname(import.meta)

const INDEX_NAME = 'somisana'

export default async ctx => {
  const { url } = ctx.request

  if (url.match(/\.js$/)) {
    ctx.set('Content-type', 'application/javascript; charset=utf-8')
    ctx.body = createReadStream(join(__dirname, `../../.cache/${url}`))
  } else {
    ctx.set('Content-type', 'text/html')

    const page = ctx.request.url.replace('.html', '').replace('/', '') || INDEX_NAME
    const htmlUtf8 = await fs.readFile(join(__dirname, `../../.cache/${page}.html`), {
      encoding: 'utf-8',
    })
    const SsrEntry = await import(join(__dirname, `../../.cache/ssr.${page}.js`)).then(
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
