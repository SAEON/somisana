export default {
  __resolveType: ({ id }) => {
    console.info('At the very least, this type resolver receives an ID', id)
    throw new Error(
      `This server doesn't support querying for interface types directly, as this requires resolving concrete types via ID specifiers and parsed query (difficult). Also if we do resolve the interface types, then other type resolvers need to resolve fields via database trips implemented per field resolver which is not needed right now`
    )
  },
}
