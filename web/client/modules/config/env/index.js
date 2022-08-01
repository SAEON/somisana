export const NODE_ENV = process.env.NODE_ENV
export const API = process.env.API
export const TILESERV_BASE_URL = process.env.TILESERV_BASE_URL
export const ORIGIN = API
export const API_HTTP = `${API}/http`
export const API_GQL = `${API}/graphql`
export const TECHNICAL_CONTACT =
  process.env.TECHNICAL_CONTACT || 'Missing configuration value [TECHNICAL_CONTACT]'
