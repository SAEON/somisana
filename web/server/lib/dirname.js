import { dirname } from 'path'
import { fileURLToPath } from 'url'

export default meta => dirname(fileURLToPath(meta.url))
