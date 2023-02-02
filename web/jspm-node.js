import { Generator } from '@jspm/generator'
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
    'apollo-server-core',
    'apollo-server-koa',
    'apollo-server-plugin-response-cache',
    'koa-bodyparser',
    'pg',
    'pg-query-stream',
    'JSONStream',
  ],
})

await Promise.all(DEPS.split(':').map(dep => generator.traceInstall('./' + dep)))

mkdirp.sync(dirname(TARGET))
await writeFile(TARGET, JSON.stringify(generator.getMap(), null, 2))
