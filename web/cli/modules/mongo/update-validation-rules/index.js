import { withFlags, describe } from '@saeon/cli-tools'
import runCommand from './_run.js'

const run = async (args = {}) => {
  let { run, help } = args
  if (!run) help = true

  if (run) {
    return await runCommand()
  }

  if (help) {
    console.info(
      'Help -- NOT IMPLEMENTED (but you probably want to specify the "run" flag (-r or --run)'
    )
    return
  }

  console.error('Unknown / unspecified option', args)
}

export default describe(
  withFlags(run, {
    help: Boolean,
    run: Boolean,
    h: 'help',
    r: 'run',
  }),
  {
    title: 'sdp :: mongo :: update validation rules',
    description: 'Update collection validation rules',
  }
)
