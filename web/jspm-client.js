import { Generator } from './@jspm/generator/dist/generator.js'
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
  ignore: [
    
  ]
})

const htmlSource = await readFile(DEP, 'utf-8')
const pins = await generator.addMappings(htmlSource)
const html = await generator.htmlInject(htmlSource, {
  trace: true,
  pins,
  preload: false,
  integrity: false,
  esModuleShims: true,
})

mkdirp.sync(dirname(TARGET))
await writeFile(TARGET, html)
