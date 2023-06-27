export default {
  name: 'permissions',
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      description: 'Permission document',
      required: ['name'],
      properties: {
        name: {
          bsonType: 'string',
          description: 'The name of the permission',
        },
        description: {
          bsonType: 'string',
          description: 'Description of the permission type',
        },
        documentTypePermissions: {
          bsonType: 'object',
          description:
            'Allows for checking user permissions against certain document types in a collection',
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
