import '../../css/index.css'
import { API_GQL } from '../config/env'
import { hydrateRoot } from 'react-dom/client'
import App from '../../../common/app'
import { ApolloClient, InMemoryCache, HttpLink } from '@apollo/client'
import { BrowserRouter as Router } from 'react-router-dom'

const apolloClient = new ApolloClient({
  cache: new InMemoryCache({}),
  link: new HttpLink({
    uri: API_GQL,
    credentials: 'include',
  }),
})

export default Page => {
  hydrateRoot(
    document.getElementById('root'),
    <App Router={Router} apolloClient={apolloClient}>
      <Page />
    </App>
  )
}
