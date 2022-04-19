const HtmlWebPackPlugin = require('html-webpack-plugin')
const path = require('path')
const fs = require('fs')

module.exports = (ROOT, OUTPUT) => {
  const entries = fs.readdirSync(path.join(ROOT, 'clients/pages'))
  return entries
    .filter(name => fs.lstatSync(path.join(ROOT, `clients/pages/${name}`)).isDirectory())
    .map(
      name =>
        new HtmlWebPackPlugin({
          template: path.join(ROOT, `clients/pages/${name}/index.html`),
          filename: path.join(ROOT, OUTPUT, `${name}.html`),
          PUBLIC_PATH: '',
          chunks: [name],
        })
    )
}
