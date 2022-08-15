export default {
  __resolveType: ({ id }) => {
    console.info('At the very least, this type resolver receives an ID', id)
    throw new Error(
      `This server doesn't support querying for abstract types, as we can't resolve types via ID specifiers alone. Also if we do resolve abstract types then other type resolvers need to resolve fields via database trips`
    )
  },
}
