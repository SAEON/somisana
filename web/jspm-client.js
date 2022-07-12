import { Generator } from '@jspm/generator'
import { readFile, writeFile } from 'fs/promises'
import { pathToFileURL } from 'url'
import mkdirp from 'mkdirp'
import { dirname } from 'path'

const NODE_ENV = process.env.NODE_ENV || 'development'

const generator = new Generator({
  mapUrl: pathToFileURL(process.env.TARGET),
  env: ['browser', NODE_ENV, 'module'],
  defaultProvider: 'jspm',
})

const htmlSource = await readFile(process.env.DEP, 'utf-8')

mkdirp.sync(dirname(process.env.TARGET))
await writeFile(
  process.env.TARGET,
  await generator.htmlGenerate(htmlSource, {
    htmlUrl: pathToFileURL(process.env.TARGET),
    preload: false,
    integrity: false,
  })
)
