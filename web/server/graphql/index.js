import { ApolloServer } from '@apollo/server'
import { ApolloServerPluginDrainHttpServer } from '@apollo/server/plugin/drainHttpServer'
import { ApolloServerPluginLandingPageGraphQLPlayground } from '@apollo/server-plugin-landing-page-graphql-playground'
import _schema from './schema/index.js'
import responseCachePlugin from '@apollo/server-plugin-response-cache'
import { koaMiddleware } from '@as-integrations/koa'

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
  api.use(
    koaMiddleware(apolloServer, {
      context: async ({ ctx }) => {
        return ctx
      },
    })
  )

  return apolloServer
}
