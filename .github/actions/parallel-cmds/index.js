// https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action
import core from '@actions/core'
import github from '@actions/github'
import {cpus} from 'os'
import {spawn } from 'child_process'

try {
  
  let usedCores = 0
  const cores = core.getInput('cores') || cpus().length
  
  let commands = core.getInput('cmds').split('\n').map(s => s.split(' ').map(s => s.trim()).flat())

  await new Promise((resolve, reject) => {
    while (usedCores < cores && commands.length) {
      const cmd = commands.shift()
      console.log(cmd)
      usedCores ++
    }

    resolve()
  })



  // const results = await Promise.all(commands.split('\n').map(s =>  new Promise((resolve, reject) => {
  //     const [cmd, ...args] = s.trim().split(' ').map(c => c.trim())
  //     console.info('Executing cmd', cmd, args)
  //     const p = spawn(cmd, args)
  //     p.on('message', msg => console.info(msg.toString()))
  //     p.on('exit', code => {
  //       if (code === 0) {
  //         resolve()
  //       } else {
  //         reject()
  //       }
  //     })
  //   })
  // ))

  console.log('All done!')

  const time = new Date().toTimeString()
  core.setOutput('time', time)

} catch (error) {
  console.error(error.message)
  core.setFailed(error.message)
}
