import base64url from 'base64url'
import { HOSTNAME } from '../../config/index.js'

export default async ctx => {
  const { state } = ctx.request.query
  const { redirect } = JSON.parse(base64url.decode(state))
  ctx.redirect(redirect || HOSTNAME)
}
