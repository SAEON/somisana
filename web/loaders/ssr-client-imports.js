import { readFileSync } from 'fs'
import { join, normalize } from 'path'
import { fileURLToPath } from 'url'
import { dirname } from 'path'

const __dirname = dirname(fileURLToPath(import.meta.url))
const importMap = JSON.parse(readFileSync(normalize(join(__dirname, '../node.importmap'))))

export async function resolve(specifier, ctx, defaultResolve) {
  let { url } = await defaultResolve(specifier, ctx)
  let format = null
  if (importMap.scopes['https://ga.jspm.io/'][specifier]) {
    url = importMap.scopes['https://ga.jspm.io/'][specifier]
  }

  return { url, format }
}
