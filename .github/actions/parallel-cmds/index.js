// https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action
import core from '@actions/core'
import github from '@actions/github'

try {
  const commands = core.getInput('cmds')
  console.log(typeof commands, commands)

  const time = new Date().toTimeString()
  core.setOutput('time', time)

} catch (error) {
  console.error(error.message)
  core.setFailed(error.message)
}
