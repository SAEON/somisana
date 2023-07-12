import { buildCli, describe } from '@saeon/cli-tools'
import require from './lib/require.js'

const importFrom = require(import.meta)

const cli = args =>
  buildCli(
    describe(
      {
        integrations: importFrom('./modules/integrations/index.js'),
        mongo: importFrom('./modules/mongo/index.js'),
        postgres: importFrom('./modules/postgres/index.js'),
        sitemaps: importFrom('./modules/sitemaps/index.js'),
      },
      {
        title: 'SOMISANA',
        description: 'CLI tools for the SOMISANA web application',
      }
    ),
    args
  )

cli(process.argv.slice(2))
