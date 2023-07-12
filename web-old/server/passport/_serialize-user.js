import passport from 'koa-passport'
passport.serializeUser((user, cb) => cb(null, user))
