import { nanoid } from 'nanoid'
import { PASSPORT_SSO_SESSION_ID } from '../../config/index.js'

export default async (ctx, next) => {
  const protocol = ctx.protocol
  const isHttp = protocol === 'http'

  if (!ctx.cookies.get(PASSPORT_SSO_SESSION_ID)) {
    ctx.cookies.set(
      PASSPORT_SSO_SESSION_ID,
      Buffer.from(
        JSON.stringify({
          date: new Date(),
          id: nanoid(),
        })
      ).toString('base64'),
      {
        signed: true,
        httpOnly: true,
        secure: isHttp ? false : true,
        sameSite: isHttp ? 'lax' : 'none',
      }
    )
  }

  await next()
}
