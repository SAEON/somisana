// https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action
import core from '@actions/core'
import github from '@actions/github'
import {cpus} from 'os'

try {
  const cores = core.getInput('cores') || cpus().length
  const commands = core.getInput('cmds')

  console.log('cores', cores)
  console.log(typeof commands, commands)
  console.log(commands.split('\n'))

  const time = new Date().toTimeString()
  core.setOutput('time', time)

} catch (error) {
  console.error(error.message)
  core.setFailed(error.message)
}
