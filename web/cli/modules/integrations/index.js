import { describe, withFlags } from '@saeon/cli-tools'
import lacce from '../../../integrations/lacce/index.js'
import marineHeatWaves from '../../../integrations/marine-heat-waves/index.js'

export default describe(
  {
    lacce: describe(
      withFlags(async args => {
        await lacce()
      }, {}),
      {
        title: 'LACCE',
        description: "Identify the Location of the Agulhas Current's Core and Edges (LACCE)",
      }
    ),
    mhw: describe(
      withFlags(async args => {
        await marineHeatWaves()
      }, {}),
      {
        title: 'Marine Heat Waves',
        description: 'Identify the spatial extent marine heat waves',
      }
    ),
  },
  { title: 'Integration scripts', description: 'Integration CLI tooling' }
)
