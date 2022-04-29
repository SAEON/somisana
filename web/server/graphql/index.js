import { ApolloServer } from 'apollo-server-koa'
import {
  ApolloServerPluginDrainHttpServer,
  ApolloServerPluginLandingPageGraphQLPlayground
} from 'apollo-server-core'
import _schema from './schema/index.js'

export const schema = _schema

export default async ({ httpServer, api }) => {
  const apolloServer = new ApolloServer({
    uploads: false,
    schema,
    introspection: true,
    plugins: [
      ApolloServerPluginDrainHttpServer({ httpServer }),
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

  await apolloServer.start()
  apolloServer.applyMiddleware({ app: api, cors: false })

  return apolloServer
}
