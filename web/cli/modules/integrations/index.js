import { describe } from '@saeon/cli-tools'

export default describe(
  {
    stub: () => console.log('working'),
  },
  { title: 'Integration scripts', description: 'Integration CLI tooling' }
)
