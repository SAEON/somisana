import { Generator } from './@jspm/generator/dist/generator.js'
import { writeFile } from 'fs/promises'
import mkdirp from 'mkdirp'
import { dirname } from 'path'

const NODE_ENV = process.env.NODE_ENV || 'development'
const DEPS = process.env.DEPS
const TARGET = process.env.TARGET

const generator = new Generator({
  mapUrl: import.meta.url,
  env: ['node', NODE_ENV, 'module'],
  defaultProvider: 'jspm',
  ignore: [
    'mongodb',
    'graphql',
    'apollo-server-core',
    'apollo-server-koa',
    'apollo-server-plugin-response-cache',
    'koa-bodyparser',
    'http-errors',
    'pg',
    'pg-query-stream',
    'JSONStream',
    'mime',
    'cacache'
  ],
})

await Promise.all(DEPS.split(':').map(dep => generator.traceInstall('./' + dep)))

mkdirp.sync(dirname(TARGET))
await writeFile(TARGET, JSON.stringify(generator.getMap(), null, 2))
