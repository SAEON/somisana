/**
 * This function decorates GraphQL resolvers (self, args, ctx) => ...
 */
export const authorizeGql =
  ({ permission, resourceOwner = false }) =>
  op =>
  async (...args) => {
    const [, , ctx] = args
    const { user } = ctx
    if (!resourceOwner) {
      await user.ensurePermission({ ctx, permission })
    }
    return op(...args)
  }

/**
 * This function decorates HTTP routes (ctx) => ...
 */
export const authorizeHttp =
  ({ permission, resourceOwner = false }) =>
  op =>
  async (...args) => {
    const [ctx] = args
    const { user } = ctx
    if (!resourceOwner) {
      await user.ensurePermission({ ctx, permission })
    }
    return op(...args)
  }
