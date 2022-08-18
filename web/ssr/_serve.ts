import { createReadStream } from 'fs'
import { join, normalize } from 'path'

export default (ctx, { files, url }) => createReadStream(normalize(join(files, url)))
