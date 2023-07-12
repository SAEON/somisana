export default {
  id: async ({ id }) => `pg_models__${id}`,
  _id: async ({ id }) => id,
  envelope: async ({ envelope }) => JSON.parse(envelope),
  convexhull: async ({ convexhull }) => JSON.parse(convexhull),
  gridWidth: async ({ grid_width: gridWidth }) => gridWidth,
  gridHeight: async ({ grid_height: gridHeight }) => gridHeight,
  creatorContactEmail: async ({ creator_contact_email: creatorContactEmail }) =>
    creatorContactEmail,
}
