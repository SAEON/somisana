export default {
  __resolveType: ({ _gqlType }) => {
    if (!_gqlType) {
      throw new Error(
        `Resolves must append a "_gqlType" field to every object so that the concrete type can be worked out when resolving objects that implement the Node interface`
      )
    }
    return _gqlType
  },
}
