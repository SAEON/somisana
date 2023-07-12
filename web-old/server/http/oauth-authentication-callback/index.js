import passport from 'koa-passport'

export default async (ctx, next) => passport.authenticate('oidc')(ctx, next)
