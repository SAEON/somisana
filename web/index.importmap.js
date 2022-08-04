// import { readdir } from 'fs/promises'

// SERVER
import './server/index.js'

// CLIENT
import './.cache/ssr.algoa-bay-forecast.js'
import './.cache/ssr.false-bay-forecast.js'
import './.cache/ssr.somisana.js'
import './.cache/ssr.esri-atlas.js'
import './.cache/ssr.maplibre-atlas.js'

/**
 * NOTE
 * Currently jspm/generator doesn't support string evaluation
 */

// readdir('./.cache')
//   .then(files => files.filter(f => f.startsWith('ssr.')))
//   .then(entryPoints => entryPoints.forEach(js => console.log(`./.cache/${js}`)))
