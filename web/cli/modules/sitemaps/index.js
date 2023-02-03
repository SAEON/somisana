import { describe, withFlags } from '@saeon/cli-tools'

export default describe(
  withFlags(
    async args => {
      await new Promise(res => setTimeout(res, 1000))
      console.log('args', args)
    },
    {
      run: Boolean,
      r: 'run',
    }
  ),
  { title: 'Sitemaps', description: 'Generate sitemap files' }
)
