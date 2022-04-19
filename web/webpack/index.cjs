const fs = require('fs')
const path = require('path')
const loadEntryPoints = require('./_load-entry-points.cjs')

const MODE = process.env.MODE || 'development'
const ROOT = path.normalize(path.join(__dirname, '../'))
const OUTPUT = 'server/ssr/dist'

const entries = Object.fromEntries(
  fs
    .readdirSync(path.join(ROOT, '.clients_build/pages'))
    .filter(name => fs.lstatSync(path.join(ROOT, `.clients_build/pages/${name}`)).isDirectory())
    .map(name => [name, path.join(ROOT, `.clients_build/pages/${name}/index.js`)])
)

module.exports = () => {
  return {
    mode: MODE,
    devtool: false,
    target: MODE === 'production' ? ['web', 'es5'] : 'web',
    entry: entries,
    output: {
      filename: '[name].[contenthash].js',
      chunkFilename: '[name].[contenthash].js',
      path: path.join(ROOT, OUTPUT),
      publicPath: '/',
      assetModuleFilename: 'assets/[hash][ext][query]',
    },
    resolve: {
      extensions: ['.ts', '.tsx', '.js', '.jsx'],
      alias: {}
    },
    optimization: {
      minimize: MODE === 'development' ? false : true,
      splitChunks: { chunks: 'all' },
    },
    module: {
      rules: [],
    },
    plugins: [
      ...loadEntryPoints(ROOT, OUTPUT),
    ],
  }
}