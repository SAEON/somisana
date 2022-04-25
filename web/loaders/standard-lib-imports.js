/**
 * TODO
 *
 * It would be better if the import maps ommitted the std lib
 * imports for node, or if the imports then worked
 */
export async function resolve(specifier, ctx, defaultResolve) {
  let { url } = await defaultResolve(specifier, ctx)
  if (specifier.match(/node\:/)) {
    url = specifier
  }

  return { url, format: null }
}
