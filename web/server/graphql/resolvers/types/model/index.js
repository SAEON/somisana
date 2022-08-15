export default {
  id: async ({ id }) => `pg_models__${id}`,
  _id: async ({ id }) => id,
  envelope: async ({ envelope }) => JSON.parse(envelope),
  convexhull: async ({ convexhull }) => JSON.parse(convexhull),
}
