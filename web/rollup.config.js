import swc from 'rollup-plugin-swc'
import { dirname } from 'path'
import { fileURLToPath } from 'url'
import { join } from 'path'
import fs from 'fs'

const __dirname = dirname(fileURLToPath(import.meta.url))

export default {
  external: ['react', 'react/jsx-runtime', 'react-dom/client'],
  input: fs
    .readdirSync(join(__dirname, 'clients/pages'))
    .filter(name => fs.lstatSync(join(__dirname, `clients/pages/${name}`)).isDirectory())
    .map(name =>
      fs
        .readdirSync(join(__dirname, `clients/pages/${name}`))
        .map(f => join(__dirname, `clients/pages/${name}/${f}`))
    )
    .flat(),
  output: [
    {
      exports: 'auto',
      dir: '.cache',
      format: 'esm',
      compact: false,
      entryFileNames: ({ facadeModuleId: id }) => {
        const p = id.split('/')
        return `[name].${p[p.length - 2]}.js`
      },
    },
  ],
  plugins: [swc()],
}
