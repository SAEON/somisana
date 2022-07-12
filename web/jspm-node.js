import { Generator } from '@jspm/generator'
import { writeFile } from 'fs/promises'
import mkdirp from 'mkdirp'
import { dirname } from 'path'

const NODE_ENV = process.env.NODE_ENV || 'development'

const generator = new Generator({
  mapUrl: import.meta.url,
  env: ['node', NODE_ENV, 'module'],
  defaultProvider: 'jspm',
  ignore: [
    'mongodb',
    'graphql',
    'apollo-server-core',
    'apollo-server-koa',
    'koa-bodyparser',
    'http-errors',
  ],
})

await Promise.all(process.env.DEPS.split(':').map(dep => generator.traceInstall('./' + dep)))

mkdirp.sync(dirname(process.env.TARGET))
await writeFile(process.env.TARGET, JSON.stringify(generator.getMap(), null, 2))
