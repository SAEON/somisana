import { readFileSync } from 'fs'
import { join, normalize } from 'path'
import { fileURLToPath } from 'url'
import { dirname } from 'path'

const __dirname = dirname(fileURLToPath(import.meta.url))
const importMap = JSON.parse(readFileSync(normalize(join(__dirname, '../../node.importmap'))))

export async function resolve(specifier, ctx, nextResolve) {
  let url
  let format = null

  if (importMap.imports[specifier]) {
    url = importMap.imports[specifier]
  } else if (importMap.scopes['./'][specifier]) {
    url = importMap.scopes['./'][specifier]
  } else if (importMap.scopes['https://ga.jspm.io/'][specifier]) {
    url = importMap.scopes['https://ga.jspm.io/'][specifier]
  }

  if (!url) {
    url = (await nextResolve(specifier, ctx)).url
  }

  return { url, format, shortCircuit: true }
}
