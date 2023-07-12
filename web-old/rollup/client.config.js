import _swc from 'rollup-plugin-swc'
import replace from '@rollup/plugin-replace'
import { dirname, normalize } from 'path'
import { fileURLToPath } from 'url'
import { join } from 'path'
import { readdirSync, lstatSync, readFileSync } from 'fs'
import * as rimraf from 'rimraf'
import extensions from './plugins/extensions.js'
import css from 'rollup-plugin-import-css'
import 'dotenv/config'

const { default: swc } = _swc

const __dirname = dirname(fileURLToPath(import.meta.url))

rimraf.sync(join(__dirname, '../.client/*.js'))

const PACKAGE_JSON = readFileSync(normalize(join(__dirname, '../package.json'))).toString('utf8')
const NODE_ENV = process.env.NODE_ENV || 'development'
const HOSTNAME = process.env.HOSTNAME || 'http://localhost:3000'
const TILESERV_BASE_URL = process.env.TILESERV_BASE_URL || 'http://localhost:7800'
const FEATURESERV_BASE_URL = process.env.FEATURESERV_BASE_URL || 'http://localhost:9000'
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
      dir: '.client',
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
        if (parentId && !id.startsWith('../') && !id.startsWith('./')) {
          return { id, external: true }
        }
      },
    },
    replace({
      preventAssignment: true,
      'process.env.NODE_ENV': JSON.stringify(NODE_ENV),
      'process.env.HOSTNAME': JSON.stringify(HOSTNAME),
      'process.env.TECHNICAL_CONTACT': JSON.stringify(TECHNICAL_CONTACT),
      'process.env.TILESERV_BASE_URL': JSON.stringify(TILESERV_BASE_URL),
      'process.env.FEATURESERV_BASE_URL': JSON.stringify(FEATURESERV_BASE_URL),
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
