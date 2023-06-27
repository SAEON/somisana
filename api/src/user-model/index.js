import ensureAuthenticated_ from './_ensure-authenticated.js'
import ensurePermission_ from './_ensure-permission.js'

export const ensureAuthenticated = ensureAuthenticated_

export const ensurePermission = ensurePermission_

export default {
  info: ctx => ctx.userInfo,
  ensureAuthenticated: ctx => ensureAuthenticated_(ctx),
  ensurePermission: ({ ctx, permission }) => ensurePermission_(ctx, permission),
  ensurePermissions: ({ ctx, permissions }) => ensurePermission_(ctx, ...permissions),
}
