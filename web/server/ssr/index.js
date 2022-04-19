import { renderToString } from 'react-dom/server'
import { join } from 'path'
import fs from 'fs/promises'
import dirname from '../lib/dirname.js'

const __dirname = dirname(import.meta)

export default async ctx => {
  const html = await fs.readFile(join(__dirname, './dist/pages/algoa-bay-forecast/index.html'))
  const { Page } = await import('./dist/pages/algoa-bay-forecast/index.js')

  ctx.set('Content-type', 'text/html')
  ctx.body = html
    .toString('utf8')
    .replace('<div id="root"></div>', `<div id="root">${renderToString(Page())}</div>`)
}
