import { describe } from '@saeon/cli-tools'
import require from '../../lib/require.js'

const importFrom = require(import.meta)

export default describe(
  {
    updateValidation: importFrom('./update-validation-rules/index.js'),
  },
  { title: 'Mongo scripts', description: 'MongoDB scripts' }
)
