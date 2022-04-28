import swc from 'rollup-plugin-swc'
import replace from '@rollup/plugin-replace'
import { dirname } from 'path'
import { fileURLToPath } from 'url'
import { join } from 'path'
import fs from 'fs'
import rimraf from 'rimraf'

const NODE_ENV = process.env.NODE_ENV || 'development'

const __dirname = dirname(fileURLToPath(import.meta.url))

rimraf.sync(join(__dirname, '../.cache'))

export default {
  input: fs
    .readdirSync(join(__dirname, '../client/pages'))
    .filter(name => fs.lstatSync(join(__dirname, `../client/pages/${name}`)).isDirectory())
    .map(name =>
      fs
        .readdirSync(join(__dirname, `../client/pages/${name}`))
        .filter(n => fs.lstatSync(join(__dirname, `../client/pages/${name}/${n}`)).isFile())
        .map(f => join(__dirname, `../client/pages/${name}/${f}`))
    )
    .flat(),
  output: [
    {
      exports: 'auto',
      dir: '.cache',
      format: 'esm',
      compact: false,
      entryFileNames: ({ facadeModuleId: id }) => {
        const p = id.split('/')
        return `[name].${p[p.length - 2]}.js`
      },
    },
  ],
  plugins: [
    {
      resolveId(id, parentId) {
        if (parentId && !id.startsWith('../') && !id.startsWith('./')) return { id, external: true }
      },
    },
    replace({
      preventAssignment: true,
      'process.env.NODE_ENV': JSON.stringify(NODE_ENV),
    }),
    swc(),
  ],
}
