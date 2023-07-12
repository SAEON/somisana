import passport from 'koa-passport'
passport.deserializeUser((user, cb) => cb(null, user))
