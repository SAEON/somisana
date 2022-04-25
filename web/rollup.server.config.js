import swc from 'rollup-plugin-swc'

export default {
  external: [
    'regenerator-runtime',
'https://ga.jspm.io/npm:react-dom@18.0.0/dev.server.node.js',
'path',
'fs/promises',
'fs',
'url',
'react/jsx-runtime'
  ],
  input: ['server/ssr/src/index.js'],
  output: [
    {
      exports: 'auto',
      dir: 'server/ssr',
      format: 'esm',
      compact: false
    }
  ],
  plugins: [
    swc()
  ]
}
