import { HOSTNAME } from './_app.js'

export const ODP_ADDRESS = process.env.ODP_ADDRESS || 'https://odp.saeon.ac.za'
export const ODP_AUTH = `${ODP_ADDRESS}/auth`
export const ODP_AUTH_WELL_KNOWN = `${ODP_AUTH}/.well-known/openid-configuration`
export const ODP_AUTH_LOGOUT_REDIRECT = `${ODP_AUTH}/oauth2/sessions/logout`
export const ODP_SSO_CLIENT_ID = process.env.ODP_SSO_CLIENT_ID || 'SAEON.DataPortal'
export const ODP_SSO_CLIENT_SECRET = process.env.ODP_SSO_CLIENT_SECRET || ''
export const ODP_SSO_CLIENT_SCOPES = process.env.ODP_SSO_CLIENT_SCOPES || 'openid SAEON.DataPortal'
export const ODP_SSO_CLIENT_REDIRECT =
  process.env.ODP_SSO_CLIENT_REDIRECT || `${HOSTNAME}/http/authenticate/redirect`
export const PASSPORT_SSO_SESSION_ID = process.env.PASSPORT_SSO_SESSION_ID || 'somisana.client.sess'
export const PASSPORT_SSO_MAXAGE_HOURS = 12
