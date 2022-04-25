import swc from 'rollup-plugin-swc'
import replace from '@rollup/plugin-replace'
import { dirname } from 'path'
import { fileURLToPath } from 'url'
import { join } from 'path'
import fs from 'fs'

const NODE_ENV = process.env.NODE_ENV || 'development'

const __dirname = dirname(fileURLToPath(import.meta.url))

export default {
  external: ['react', 'react/jsx-runtime', 'react-dom/client', 'react-dom/server', /\@mui\/material/],
  input: fs
    .readdirSync(join(__dirname, 'client/pages'))
    .filter(name => fs.lstatSync(join(__dirname, `client/pages/${name}`)).isDirectory())
    .map(name =>
      fs
        .readdirSync(join(__dirname, `client/pages/${name}`))
        .map(f => join(__dirname, `client/pages/${name}/${f}`))
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
      }
    }
  ],
  plugins: [
    replace({
      preventAssignment: true,
      'process.env.NODE_ENV': JSON.stringify(NODE_ENV)
    }),
    swc()
  ]
}
