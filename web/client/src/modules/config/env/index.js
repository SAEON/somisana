export const NODE_ENV = process.env.NODE_ENV
export const REACT_APP_HOSTNAME = process.env.REACT_APP_HOSTNAME || 'http://localhost:3001'
export const REACT_APP_API_ADDRESS = process.env.REACT_APP_API_ADDRESS || 'http://localhost:3000'
export const REACT_APP_TILESERV_BASE_URL = process.env.REACT_APP_TILESERV_BASE_URL
export const REACT_APP_ESRI_API_KEY = process.env.REACT_APP_ESRI_API_KEY
export const REACT_APP_TECHNICAL_CONTACT =
  process.env.REACT_APP_TECHNICAL_CONTACT ||
  'Missing configuration value [REACT_APP_TECHNICAL_CONTACT]'

export const ORIGIN = REACT_APP_HOSTNAME
export const ESRI_BASEMAP = 'arcgis-oceans'
export const API_HTTP = `${REACT_APP_API_ADDRESS}/http`
export const API_GQL = `${REACT_APP_API_ADDRESS}/graphql`
