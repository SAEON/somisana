import passport from 'koa-passport'
import { ODP_SSO_CLIENT_SECRET, ODP_SSO_CLIENT_ID, ODP_AUTH_WELL_KNOWN } from '../config/index.js'
import { Issuer } from 'openid-client'
import makeStrategy from './_strategy.js'
import './_serialize-user.js'
import './_deserialize-user.js'

if (!ODP_SSO_CLIENT_ID || !ODP_SSO_CLIENT_SECRET) {
  console.error('OAUTH credentials not provided')
  process.exit(1)
}

const RETRY_IN = 30 // seconds

;(async function configurePassport() {
  try {
    const issuer = await Issuer.discover(ODP_AUTH_WELL_KNOWN)
    passport.use('oidc', makeStrategy(issuer))
    console.info('Authentication configured successfully')
  } catch (error) {
    console.error('Unable to configure oauth2 oidc strategy', error)
    console.info(`Trying again to configure authentication in ${RETRY_IN} seconds`)
    await new Promise(res => setTimeout(res, RETRY_IN * 1000))
    configurePassport()
  }
})()
