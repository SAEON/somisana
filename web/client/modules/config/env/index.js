export const NODE_ENV = process.env.NODE_ENV
export const API = process.env.API
export const TILESERV_BASE_URL = process.env.TILESERV_BASE_URL
export const FEATURESERV_BASE_URL = process.env.FEATURESERV_BASE_URL
export const ESRI_API_KEY = process.env.ESRI_API_KEY
export const ORIGIN = API
export const ESRI_BASEMAP = 'arcgis-oceans'
export const API_HTTP = `${API}/http`
export const API_GQL = `${API}/graphql`
export const TECHNICAL_CONTACT =
  process.env.TECHNICAL_CONTACT || 'Missing configuration value [TECHNICAL_CONTACT]'

/* Client only */
let importMap = undefined
let packageJson = undefined

if (process.env.PACKAGE_JSON) {
  packageJson = JSON.parse(process.env.PACKAGE_JSON)
}

if (typeof window !== 'undefined') {
  importMap = JSON.parse(
    [...document.getElementsByTagName('script')].find(({ type }) => type === 'importmap').innerHTML
  )
}

export const IMPORT_MAP = importMap
export const PACKAGE_JSON = packageJson
