export async function resolve(specifier, ctx, nextResolve) {
  let { url } = await nextResolve(specifier, ctx).catch(error => {
    console.error('Error resolving specifier', specifier, 'parentURL', ctx.parentURL)
    throw error
  })

  if (specifier.match(/node\:/)) {
    url = specifier
  }

  if (specifier.match(/readable-stream/)) {
    url = 'node:stream'
  }

  return { url, format: null }
}
