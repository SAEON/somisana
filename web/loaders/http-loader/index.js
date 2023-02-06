import fetch from 'make-fetch-happen'
import { HTTP_IMPORT_CACHING, HTTP_IMPORT_CACHDIR } from './_cache-dir.js'

export function resolve(specifier, ctx, nextResolve) {
  const { parentURL = null } = ctx

  if (useLoader(specifier)) {
    return {
      format: null,
      url: specifier,
      shortCircuit: true,
    }
  } else if (parentURL && useLoader(parentURL)) {
    if (specifier.startsWith('./') || specifier.startsWith('../')) {
      return {
        format: null,
        shortCircuit: true,
        url: new URL(specifier, parentURL).href,
      }
    } else {
      ctx.parentURL = undefined
      return nextResolve(specifier, ctx)
    }
  }

  return nextResolve(specifier, ctx)
}

export async function load(url, context, nextLoad) {
  if (useLoader(url)) {
    let format
    // TODO: maybe change to content-type / mime type check rather than file extensions
    if (url.endsWith('.mjs')) {
      format = 'module'
    } else if (url.endsWith('.cjs')) {
      format = 'commonjs'
    } else if (url.endsWith('.wasm')) {
      format = 'wasm'
    } else if (url.endsWith('.json')) {
      format = 'json'
    } else {
      // default to true, since NodeJS loaders only are triggered by ESM code
      // Alternatively, we could consider looking up the nearest package.json to the process.cwd()
      // And seeing if it has `"type": "module"`
      format = 'module'
    }

    let source

    const httpResponse = await fetch(url, {
      cachePath: HTTP_IMPORT_CACHDIR,
      cache: HTTP_IMPORT_CACHING,
    })

    if (httpResponse.ok) {
      source = await httpResponse.text()
    } else {
      throw Error(
        `Request to download javascript code from ${url} failed with HTTP status ${httpResponse.status} ${httpResponse.statusText}`
      )
    }

    return {
      source,
      format,
      shortCircuit: true,
    }
  }

  return nextLoad(url, context, nextLoad)
}

function useLoader(url) {
  return url.startsWith('http://') || url.startsWith('https://')
}
