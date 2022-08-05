import swc from 'rollup-plugin-swc'
import replace from '@rollup/plugin-replace'
import { dirname, normalize } from 'path'
import { fileURLToPath } from 'url'
import { join } from 'path'
import { readdirSync, lstatSync, readFileSync } from 'fs'
import rimraf from 'rimraf'
import extensions from './plugins/extensions.js'
import css from 'rollup-plugin-import-css'
import 'dotenv/config'

const __dirname = dirname(fileURLToPath(import.meta.url))

rimraf.sync(join(__dirname, '../.cache/*.js'))

const PACKAGE_JSON = readFileSync(normalize(join(__dirname, '../package.json'))).toString('utf8')
const NODE_ENV = process.env.NODE_ENV || 'development'
const API = process.env.API || 'http://localhost:3000'
const TILESERV_BASE_URL = process.env.TILESERV_BASE_URL || 'http://localhost:7800'
const ESRI_API_KEY = process.env.ESRI_API_KEY || 'missing'
const TECHNICAL_CONTACT =
  process.env.TECHNICAL_CONTACT || 'Missing configuration (TECHNICAL_CONTACT)'

export default {
  input: readdirSync(join(__dirname, '../client/pages'))
    .filter(name => lstatSync(join(__dirname, `../client/pages/${name}`)).isDirectory())
    .map(name =>
      readdirSync(join(__dirname, `../client/pages/${name}`))
        .filter(n => {
          const p = join(__dirname, `../client/pages/${name}/${n}`)
          return lstatSync(p).isFile() && !p.endsWith('.html')
        })
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
    extensions({
      extensions: ['.tsx', '.ts', '.jsx', '.js'],
      resolveIndex: true,
    }),
    {
      resolveId(id, parentId) {
        if (parentId && !id.startsWith('../') && !id.startsWith('./')) return { id, external: true }
      },
    },
    replace({
      preventAssignment: true,
      'process.env.NODE_ENV': JSON.stringify(NODE_ENV),
      'process.env.API': JSON.stringify(API),
      'process.env.TECHNICAL_CONTACT': JSON.stringify(TECHNICAL_CONTACT),
      'process.env.TILESERV_BASE_URL': JSON.stringify(TILESERV_BASE_URL),
      'process.env.ESRI_API_KEY': JSON.stringify(ESRI_API_KEY),
      'process.env.PACKAGE_JSON': JSON.stringify(PACKAGE_JSON),
    }),
    css({
      output: 'index.css',
      alwaysOutput: true,
      minify: NODE_ENV === 'production' ? true : false,
      transform: null,
    }),
    swc({ configFile: join(__dirname, '../.swcrc') }),
  ],
}
