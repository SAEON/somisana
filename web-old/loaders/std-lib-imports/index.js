export async function resolve(specifier, ctx, nextResolve) {
  if (specifier.match(/readable-stream/)) {
    return {
      url: 'node:stream',
      shortCircuit: true,
      format: null,
    }
  }

  return nextResolve(specifier, ctx)
}
