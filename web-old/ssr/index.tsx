import { join, normalize } from 'path'
import streamFile from './_stream-file'
import renderHTML from './_render-html'
import mime from 'mime'
import rewrite from './_url-rewrite'
import { assetsPath, htmlFiles } from './_register-assets'

export default async (ctx: any) => {
  const url = rewrite(ctx.request.url)
  const contentType = mime.getType(url)
  const assetPath = normalize(join(assetsPath, url))

  switch (contentType) {
    case 'text/html':
    case null:
      await renderHTML(ctx, htmlFiles, assetsPath)
      break

    default:
      await streamFile(ctx, contentType, assetPath)
      break
  }
}
