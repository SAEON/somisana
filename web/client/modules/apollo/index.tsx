import { useContext } from 'react'
import { ctx as configCtx } from '../config'
import { ApolloProvider, ApolloClient, InMemoryCache, HttpLink } from '@apollo/client'

export default ({ children }) => {
  const { API_GQL } = useContext(configCtx)

  return (
    <ApolloProvider
      client={
        new ApolloClient({
          cache: new InMemoryCache({}),
          link: new HttpLink({
            uri: API_GQL,
            credentials: 'include',
          }),
        })
      }
    >
      {children}
    </ApolloProvider>
  )
}
