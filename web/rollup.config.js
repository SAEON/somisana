import swc from 'rollup-plugin-swc'

export default {
  external: ['react', 'react/jsx-runtime', 'react-dom/client'],
  input: [
    'clients/pages/algoa-bay-forecast/index.js',
    'clients/pages/algoa-bay-forecast/ssr.js',
    'clients/pages/false-bay-forecast/index.js',
    'clients/pages/false-bay-forecast/ssr.js',
  ],
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
