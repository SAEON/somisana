import { renderToString } from 'react-dom/server'
import { join } from 'path'
import fs from 'fs/promises'
import dirname from '../lib/dirname.js'
import { createReadStream } from 'fs'

const __dirname = dirname(import.meta)

export default async ctx => {
  const { url } = ctx.request

  if (url.match(/\.js$/)) {
    ctx.set('Content-type', 'application/javascript; charset=utf-8')
    if (url === '/index.js' || url === '/page.js') {
      ctx.body = createReadStream(join(__dirname, `./dist/pages/algoa-bay-forecast${url}`))
    } else {
      ctx.body = createReadStream(join(__dirname, `./dist/${url}`))
    }
  } else {
    const html = await fs.readFile(join(__dirname, './dist/pages/algoa-bay-forecast/index.html'))
    const { default: Page } = await import('./dist/pages/algoa-bay-forecast/page.js')

    ctx.set('Content-type', 'text/html')
    ctx.body = html
      .toString('utf8')
      .replace('<div id="root"></div>', `<div id="root">${renderToString(Page())}</div>`)
  }
}
