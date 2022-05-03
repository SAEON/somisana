import CssBaseline from '@mui/material/CssBaseline'
import { ThemeProvider } from '@mui/material/styles'
import { CacheProvider as EmotionCacheProvider } from '@emotion/react'
import { StaticRouter } from 'react-router-dom/server'
import { ApolloProvider, ApolloClient, createHttpLink, InMemoryCache } from '@apollo/client'
import theme from '../../../theme/mui/index.js'
import fetch from 'node-fetch'

export default ({ children, emotionCache, ctx }) => (
  <EmotionCacheProvider value={emotionCache}>
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
          <StaticRouter location={ctx.request.url} context={{}}>
            {children}
          </StaticRouter>
        </ApolloProvider>
      </CssBaseline>
    </ThemeProvider>
  </EmotionCacheProvider>
)
