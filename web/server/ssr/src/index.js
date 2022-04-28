import { renderToString } from 'react-dom/server'
import { join } from 'path'
import fs from 'fs/promises'
import fetch from 'node-fetch'
import dirname from '../../lib/dirname.js'
import { createReadStream } from 'fs'
import { ApolloProvider, ApolloClient, createHttpLink, InMemoryCache } from '@apollo/client'
import theme from '../../../theme/mui/index.js'
import createEmotionCache from '../../../create-emotion-cache.js'
import CssBaseline from '@mui/material/CssBaseline'
import { ThemeProvider } from '@mui/material/styles'
import { CacheProvider } from '@emotion/react'
import emotionServer from '@emotion/server/create-instance'
import { StaticRouter } from 'react-router-dom/server'

const { default: createEmotionServer } = emotionServer

const __dirname = dirname(import.meta)

export default async ctx => {
  const { url } = ctx.request

  if (url.match(/\.js$/)) {
    ctx.set('Content-type', 'application/javascript; charset=utf-8')
    ctx.body = createReadStream(join(__dirname, `../../.cache/${url}`))
  } else {
    ctx.set('Content-type', 'text/html')

    const page = ctx.request.url.replace('.html', '').replace('/', '')
    const htmlUtf8 = await fs.readFile(join(__dirname, `../../.cache/${page}.html`), {
      encoding: 'utf-8',
    })
    const SsrEntry = await import(join(__dirname, `../../.cache/ssr.${page}.js`)).then(
      ({ default: C }) => C
    )

    const cache = createEmotionCache()
    const { extractCriticalToChunks, constructStyleTagsFromChunks } = createEmotionServer(cache)

    const html = renderToString(
      <CacheProvider value={cache}>
        <ThemeProvider theme={theme}>
          <CssBaseline>
            <ApolloProvider
              client={
                new ApolloClient({
                  ssrMode: true,
                  link: createHttpLink({
                    fetch,
                    uri: 'http://localhost:3000/graphql',
                    credentials: 'same-origin',
                    headers: {
                      cookie: ctx.get('Cookie'),
                    },
                  }),
                  cache: new InMemoryCache(),
                })
              }
            >
              <StaticRouter location={url} context={{}}>
                <SsrEntry />
              </StaticRouter>
            </ApolloProvider>
          </CssBaseline>
        </ThemeProvider>
      </CacheProvider>
    )

    const emotionChunks = extractCriticalToChunks(html)
    const emotionCss = constructStyleTagsFromChunks(emotionChunks)

    const result = htmlUtf8
      .replace('</title>', `</title>${emotionCss}`)
      .replace('<div id="root"></div>', `<div id="root">${html}</div>`)

    ctx.body = result
  }
}
