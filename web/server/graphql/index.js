import { ApolloServer } from 'apollo-server-koa'
import { ApolloServerPluginLandingPageGraphQLPlayground } from 'apollo-server-core'
import _schema from './schema/index.js'

export const schema = _schema

export default new ApolloServer({
  uploads: false,
  schema,
  introspection: true,
  plugins: [
    ApolloServerPluginLandingPageGraphQLPlayground({
      settings: {
        'editor.cursorShape': 'line',
        'request.credentials': 'include',
        'editor.theme': 'light'
      }
    })
  ],
  context: ({ ctx }) => {
    return ctx
  }
})
