export default async ctx => {
  if (!ctx.userInfo) {
    ctx.throw(401)
    return
  }
}
