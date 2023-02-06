import { join } from 'path'
import { dirname } from 'path'
import { fileURLToPath } from 'url'

export const getCurrentDirectory = meta => dirname(fileURLToPath(meta.url))

/**
 * Since type="module" doesn't include __dirname,
 * This function provides an easy means of referencing
 * files from some location
 *
 * import require from './this module.js'
 * const importFrom = require(import.meta)
 *
 * importFrom('./some/relative/path.js') : Promise
 *
 * The Promise resolves to the default export
 */
export default meta => p => import(join(getCurrentDirectory(meta), p)).then(({ default: fn }) => fn)
