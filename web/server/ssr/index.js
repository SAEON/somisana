// import { renderToString } from 'react-dom/server'
import { renderToString } from 'https://ga.jspm.io/npm:react-dom@18.0.0/dev.server.node.js'
import { join } from 'path'
import fs from 'fs/promises'
import dirname from '../lib/dirname.js'
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
    const Component = await import(join(__dirname, `../../.cache/ssr.${page}.js`)).then(
      ({ default: Page }) => Page
    )

    const C = Component()

    ctx.body = html.replace('<div id="root"></div>', `<div id="root">${renderToString(C)}</div>`)
  }
}
