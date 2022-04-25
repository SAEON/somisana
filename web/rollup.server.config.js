import swc from 'rollup-plugin-swc'

export default {
  input: ['server/ssr/src/index.js'],
  output: [
    {
      exports: 'auto',
      dir: 'server/ssr',
      format: 'esm',
      compact: false,
    },
  ],
  plugins: [
    {
      resolveId(id, parentId) {
        if (parentId && !id.startsWith('../') && !id.startsWith('./')) return { id, external: true }
      },
    },
    swc(),
  ],
}
