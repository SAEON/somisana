import * as ReactDOMServer from 'react-dom/server'
import path from 'path'
import fs from 'fs/promises'
import dirname from '../lib/dirname.js'

const __dirname = dirname(import.meta)

export default async ctx => {
  ctx.body = 'hi'
}
