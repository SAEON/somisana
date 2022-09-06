// https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action
import core from '@actions/core'
import github from '@actions/github'
import {cpus} from 'os'
import {spawn } from 'child_process'

try {
  
  let usedCores = 0
  const cores = core.getInput('cores') || cpus().length
  
  let commands = core.getInput('cmds').split('\n').map(s => s.split(' ').map(s => s.trim()).flat())


    while (commands.length > 0) {
      if (usedCores < cores) {
        const [cmd, ...args] = commands.shift()
        console.info('Executing cmd', cmd, args)
        const p = spawn(cmd, args)
        p.on('message', msg => console.info(msg.toString()))
        p.on('exit', c => {
          if (c === 0) {
            usedCores --
          }
        })
        usedCores ++
      } else {
        await new Promise(res => setTimeout(res, 1000))
      }
      
    }

  console.log('All done!')

  const time = new Date().toTimeString()
  core.setOutput('time', time)

} catch (error) {
  console.error(error.message)
  core.setFailed(error.message)
}
