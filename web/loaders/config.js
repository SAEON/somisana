import * as importMapLoader from '@node-loader/import-maps'
import * as httpLoader from '@node-loader/http'
import * as json from './json.js'
import * as ssrClientImports from './ssr-client-imports.js'
import * as standardLibImports from './standard-lib-imports.js'

export default {
  loaders: [standardLibImports, ssrClientImports, importMapLoader, httpLoader, json],
}
