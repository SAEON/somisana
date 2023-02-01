export async function resolve(specifier, ctx, nextResolve) {
  let { url } = await nextResolve(specifier, ctx)
  console.log('hi', specifier)

  if (specifier.match(/node\:/)) {
    url = specifier
  }

  if (specifier.match(/readable-stream/)) {
    url = 'node:stream'
  }

  return { url, format: null }
}
