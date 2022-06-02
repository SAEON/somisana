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
  __resolveType: ({ __collection: collection }) => {
    const type = types[collection]

    if (!type) {
      throw new Error(
        'All mongo GraphQL queries should append a field "__collection" indicating the name of the collection being queried. Otherwise the Node interface can\'t be resolved'
      )
    }

    return type
  },
}
