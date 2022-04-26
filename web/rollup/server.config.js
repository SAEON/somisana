import rimraf from 'rimraf'
import swc from 'rollup-plugin-swc'
import { dirname } from 'path'
import { fileURLToPath } from 'url'
import { join } from 'path'

const __dirname = dirname(fileURLToPath(import.meta.url))

rimraf.sync(join(__dirname, '../server/ssr/index.js'))

export default {
  input: [join(__dirname, '../server/ssr/src/index.js')],
  output: [
    {
      exports: 'auto',
      dir: join(__dirname, '../server/ssr'),
      format: 'esm',
      compact: false
    }
  ],
  plugins: [
    {
      resolveId(id, parentId) {
        if (parentId && !id.startsWith('../') && !id.startsWith('./')) return { id, external: true }
      }
    },
    swc()
  ]
}
