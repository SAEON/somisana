import { StaticRouter } from 'react-router-dom/server'
import { ApolloClient, createHttpLink, InMemoryCache } from '@apollo/client'
import fetch from 'make-fetch-happen'
import App from '../common/app'
import cookie from 'cookie'
import Negotiator from 'negotiator'

const gaProperty = 'G-6ZM4ST1XCC'
const disableGaStr = 'ga-disable-' + gaProperty

const LANGS = ['en']

export default ({ children, ctx, emotionCache }) => {
  const cookieHeader = ctx.get('Cookie') || ''

  const negotiator = new Negotiator(ctx.request)
  const language = negotiator.language(LANGS)

  /**
   * Google Analytics should be disabled
   * unless specifically enabled
   */
  const cookies = cookie.parse(cookieHeader)
  if (!cookies[disableGaStr]) {
    ctx.cookies.set(disableGaStr, true, {
      path: '/',
      httpOnly: false,
      expires: new Date('Thu, 31 Dec 2099 23:59:59 UTC'),
    })
  }

  const apolloClient = new ApolloClient({
    ssrMode: true,
    link: createHttpLink({
      fetch,
      uri: 'http://localhost:3000/graphql',
      credentials: 'same-origin',
      headers: {
        cookie: cookieHeader,
      },
    }),
    cache: new InMemoryCache(),
  })

  return (
    <App
      cookie={cookieHeader}
      acceptLanguage={language}
      emotionCache={emotionCache}
      Router={(props: React.FC) => (
        <StaticRouter location={ctx.request.url} context={{}} {...props} />
      )}
      apolloClient={apolloClient}
    >
      {children}
    </App>
  )
}
