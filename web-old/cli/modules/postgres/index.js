import { describe } from '@saeon/cli-tools'

export default describe(
  {
    stub: () => console.log('working'),
  },
  { title: 'PostgreSQL scripts', description: 'PostgreSQL scripts' }
)
