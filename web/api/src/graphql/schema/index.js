import { makeExecutableSchema } from '@graphql-tools/schema'
import { join } from 'node:path'
import { readFileSync } from 'node:fs'
import dirname from '../../lib/dirname/index.js'
import * as resolvers from '../resolvers/index.js'

const _import = p =>
  readFileSync(join(dirname(import.meta), p), {
    encoding: 'utf-8',
  })

const typeDefs = `
  ${_import('./_schema.graphql')}`

const schema = makeExecutableSchema({
  typeDefs,
  resolvers,
  inheritResolversFromInterfaces: true,
})

export default schema
