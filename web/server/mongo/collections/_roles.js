export default {
  name: 'roles',
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      description: 'Role document',
      required: ['name'],
      properties: {
        name: {
          bsonType: 'string',
          description: 'The name of the role',
        },
      },
    },
  },
  indices: [
    {
      index: 'name',
      options: {
        name: 'name',
        unique: true,
      },
    },
  ],
}
