export async function resolve(specifier, ctx, defaultResolve) {
  const { url } = await defaultResolve(specifier, ctx)
  const format = url.endsWith('.geojson') ? 'json' : null
  return { url, format }
}
