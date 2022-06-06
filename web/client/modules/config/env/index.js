export const NODE_ENV = process.env.NODE_ENV || 'development'
export const API = process.env.API || 'http://localhost:3000'
export const ORIGIN = API
export const API_HTTP = `${API}/http`
export const API_GQL = `${API}/graphql`
export const TECHNICAL_CONTACT =
  process.env.TECHNICAL_CONTACT || 'Missing configuration value [TECHNICAL_CONTACT]'
