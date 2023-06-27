import { dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

export default meta => dirname(fileURLToPath(meta.url))
