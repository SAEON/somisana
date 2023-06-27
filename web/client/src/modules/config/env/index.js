export const NODE_ENV = process.env.NODE_ENV
export const HOSTNAME = process.env.HOSTNAME || 'http://localhost:3001'
export const API_ADDRESS = process.env.API_ADDRESS || 'http://localhost:3000'
export const TILESERV_BASE_URL = process.env.TILESERV_BASE_URL
export const FEATURESERV_BASE_URL = process.env.FEATURESERV_BASE_URL
export const ESRI_API_KEY = process.env.ESRI_API_KEY
export const ORIGIN = HOSTNAME
export const ESRI_BASEMAP = 'arcgis-oceans'
export const API_HTTP = `${API_ADDRESS}/http`
export const API_GQL = `${API_ADDRESS}/graphql`
export const TECHNICAL_CONTACT =
  process.env.TECHNICAL_CONTACT || 'Missing configuration value [TECHNICAL_CONTACT]'
