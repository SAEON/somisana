import { createEmotionCache } from '../common/app'
import createEmotionServer from '@emotion/server/create-instance'
import Layout from './_layout'
import { renderToString } from 'react-dom/server'
import { join, normalize } from 'path'
import fs from 'fs/promises'

const INDEX_NAME = 'somisana'

export default async (ctx, htmlFiles, assetsPath) => {
  ctx.set('Content-type', 'text/html')
  const entry = ctx.request.url.replace('.html', '').replace('/', '')
  const page = entry ? (htmlFiles.includes(entry) ? entry : INDEX_NAME) : INDEX_NAME

  const htmlUtf8 = await fs.readFile(normalize(join(assetsPath, `${page}.html`)), {
    encoding: 'utf-8',
  })

  const SsrEntry = await import(normalize(join(assetsPath, `ssr.${page}.js`))).then(
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
