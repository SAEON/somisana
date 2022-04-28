import { apolloServer } from '../index.js'
import { schema as gqlSchema } from '../graphql/index.js'

export default app => async (ctx, next) => {
  app.context.gql = {
    schema: gqlSchema,
    server: apolloServer,
  }

  await next()
}
