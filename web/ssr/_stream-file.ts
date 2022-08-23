import { open } from 'fs/promises'

export default async (ctx: any, contentType: string, filePath: string) => {
  let fd: any
  try {
    fd = await open(filePath)
  } catch (error) {
    ctx.status = 404
    return
  }

  ctx.set('Content-type', contentType)
  ctx.body = fd.createReadStream()
}
