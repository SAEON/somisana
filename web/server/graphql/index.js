import { ApolloServer } from 'apollo-server-koa'
import {
  ApolloServerPluginDrainHttpServer,
  ApolloServerPluginLandingPageGraphQLPlayground,
} from 'apollo-server-core'
import _schema from './schema/index.js'
import apolloCache from 'apollo-server-plugin-response-cache'
const { default: responseCachePlugin } = apolloCache

export const schema = _schema

export default async ({ httpServer, api }) => {
  const apolloServer = new ApolloServer({
    csrfPrevention: true,
    uploads: false,
    cache: 'bounded',
    persistedQueries: true,
    schema,
    introspection: true,
    plugins: [
      ApolloServerPluginDrainHttpServer({ httpServer }),
      ApolloServerPluginLandingPageGraphQLPlayground({
        settings: {
          'editor.cursorShape': 'line',
          'request.credentials': 'include',
          'editor.theme': 'light',
        },
      }),
      responseCachePlugin(),
    ],
    context: ({ ctx }) => {
      return ctx
    },
  })

  await apolloServer.start()
  apolloServer.applyMiddleware({ app: api, cors: false })

  return apolloServer
}
