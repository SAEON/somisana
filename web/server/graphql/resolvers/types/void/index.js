import { GraphQLScalarType } from 'graphql'

export default new GraphQLScalarType({
  description: 'Void custom scalar',
  name: 'Void',
  parseLiteral: () => null,
  parseValue: () => null,
  serialize: () => null
})
