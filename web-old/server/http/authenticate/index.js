export default async ctx => {
  if (ctx.userInfo) {
    ctx.body = ctx.userInfo
  } else {
    ctx.body = false
  }
}
