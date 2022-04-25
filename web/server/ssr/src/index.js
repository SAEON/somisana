import { renderToString } from 'react-dom/server'
import { join } from 'path'
import fs from 'fs/promises'
import dirname from '../../lib/dirname.js'
import { createReadStream } from 'fs'

const __dirname = dirname(import.meta)

export default async ctx => {
  const { url } = ctx.request

  if (url.match(/\.js$/)) {
    ctx.set('Content-type', 'application/javascript; charset=utf-8')
    ctx.body = createReadStream(join(__dirname, `../../.cache/${url}`))
  } else {
    ctx.set('Content-type', 'text/html')

    const page = ctx.request.url.replace('.html', '').replace('/', '')
    const html = await fs.readFile(join(__dirname, `../../.cache/${page}.html`), {
      encoding: 'utf-8',
    })
    const SsrEntry = await import(join(__dirname, `../../.cache/ssr.${page}.js`)).then(
      ({ default: C }) => C
    )

    const HTML = renderToString(<SsrEntry />)

    ctx.body = html.replace('<div id="root"></div>', `<div id="root">${HTML}</div>`)
  }
}
