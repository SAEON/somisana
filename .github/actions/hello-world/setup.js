import { spawn } from 'child_process'

const npmInstall = spawn('npm', ['ci', '--only', 'production'])

npmInstall.stdout.on('data', data => {
  console.log(`stdout: ${data}`)
})

npmInstall.stderr.on('data', data => {
  console.error(`stderr: ${data}`)
})

npmInstall.on('close', code => {
  console.log(`child process exited with code ${code}`)
})
