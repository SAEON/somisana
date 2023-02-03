import { describe } from '@saeon/cli-tools'

export default describe(
  {
    stub: () => console.log('working'),
  },
  { title: 'Mongo scripts', description: 'MongoDB scripts' }
)
