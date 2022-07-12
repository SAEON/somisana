import { Generator } from '@jspm/generator'
import { readFile, writeFile } from 'fs/promises'
import { pathToFileURL } from 'url'
import mkdirp from 'mkdirp'
import { dirname } from 'path'

const NODE_ENV = process.env.NODE_ENV || 'development'
const DEP = process.env.DEP
const TARGET = process.env.TARGET

const generator = new Generator({
  mapUrl: pathToFileURL(TARGET),
  env: ['browser', NODE_ENV, 'module'],
  defaultProvider: 'jspm',
})

const htmlSource = await readFile(DEP, 'utf-8')

const html = await generator.htmlGenerate(htmlSource, {
  htmlUrl: pathToFileURL(TARGET),
  preload: false,
  integrity: false,
})

mkdirp.sync(dirname(TARGET))
await writeFile(TARGET, html)
