import collections from '../../../../mongo/collections/index.js'

const types = Object.fromEntries(
  Object.entries(collections).map(([, { name, gqlType }]) => {
    if (!gqlType) {
      throw new Error(
        'All collections defined in ..../mongo/collections/index.js must have the field "gqlType"'
      )
    }
    return [name, gqlType]
  })
)

export default {
  __resolveType: ({ _gqlType, __collection: collection }) => {
    if (!(_gqlType || collection)) {
      throw new Error(
        `Resolves must append a "_gqlType" or "__collection" field to every object so that the concrete type can be worked out when resolving objects that implement the Node interface`
      )
    }
    return _gqlType || types[collection]
  },
}
