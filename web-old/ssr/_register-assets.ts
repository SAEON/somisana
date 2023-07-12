import { readdir } from 'fs/promises'
import dirname from '../server/lib/dirname'
import { join, normalize } from 'path'

const __dirname = dirname(import.meta)

export const assetsPath = normalize(join(__dirname, '../.client'))

export const htmlFiles = await readdir(normalize(join(__dirname, '../client/html')))
  .then((files: Array<string>) => files.filter((f: string) => f.includes('.html')))
  .then((files: Array<string>) => files.map((f: string) => f.replace('.html', '')))
