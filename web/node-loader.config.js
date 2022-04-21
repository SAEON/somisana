import * as importMapLoader from "@node-loader/import-maps"
import * as httpLoader from "@node-loader/http"
import * as geojson from './loaders/geojson.js'

export default {
  loaders: [
    importMapLoader,
    httpLoader,
    geojson
  ],
};