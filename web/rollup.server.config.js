import swc from 'rollup-plugin-swc'

export default {
  external: ['react', 'react/jsx-runtime', 'react-dom/client', 'react-dom/server', /\@mui\/material/],
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
