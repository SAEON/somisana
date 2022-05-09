import { StaticRouter } from 'react-router-dom/server'
import { ApolloClient, createHttpLink, InMemoryCache } from '@apollo/client'
import fetch from 'node-fetch'
import App from '../../../common/app'

export default ({ children, ctx, emotionCache }) => {
  const apolloClient = new ApolloClient({
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

  return (
    <App
      emotionCache={emotionCache}
      Router={props => <StaticRouter location={ctx.request.url} context={{}} {...props} />}
      apolloClient={apolloClient}
    >
      {children}
    </App>
  )
}
