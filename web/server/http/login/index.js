import passport from 'koa-passport'
import base64url from 'base64url'
import { HOSTNAME, ODP_SSO_CLIENT_SCOPES } from '../../config/index.js'

/**
 * If /login is called without a 'redirect'
 * query param, then the result is 'undefined' as
 * a string, which needs to be parsed to be read
 * as undefined as a JavaScript value
 */
export default async (ctx, next) =>
  passport
    .authenticate('oidc', {
      scope: ODP_SSO_CLIENT_SCOPES,
      state: base64url(
        JSON.stringify({
          redirect: ctx.request.query.redirect
            ? ctx.request.query.redirect == 'undefined'
              ? `${HOSTNAME}`
              : ctx.request.query.redirect
            : HOSTNAME,
        })
      ),
    })(ctx, next)
    .catch(error => {
      ctx.status = 500
      ctx.body = `ERROR: authentication is not configured. ${error.message}.`
    })
