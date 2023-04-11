import * as rimraf from 'rimraf'
import _swc from 'rollup-plugin-swc'
import { dirname } from 'path'
import { fileURLToPath } from 'url'
import { join, resolve } from 'path'
import extensions from './plugins/extensions.js'

const { default: swc } = _swc

const __dirname = dirname(fileURLToPath(import.meta.url))

rimraf.sync(join(__dirname, '../.ssr/index.js'))

export default {
  input: [join(__dirname, '../ssr/index.tsx')],
  output: [
    {
      exports: 'auto',
      dir: join(__dirname, '../.ssr'),
      format: 'esm',
      compact: false,
    },
  ],
  plugins: [
    extensions({
      extensions: ['.tsx', '.ts', '.jsx', '.js'],
      resolveIndex: true,
    }),
    {
      resolveId(id, parentId) {
        if (id.includes('../client')) {
          return resolve(__dirname, '../', id.replace(/.*client/, 'client'))
        }
        if (parentId && !id.startsWith('../') && !id.startsWith('./')) {
          return { id, external: true }
        }
      },
    },
    swc(),
  ],
}
