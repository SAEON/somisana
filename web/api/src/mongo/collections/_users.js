export default {
  name: 'users',
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      description: 'User document',
      required: ['emailAddress'],
      properties: {
        emailAddress: {
          bsonType: 'string',
          description: "User's email address (used as a primary key)",
        },
      },
    },
  },
  indices: [
    {
      index: 'emailAddress',
      options: {
        name: 'emailAddress',
        unique: true,
      },
    },
  ],
}
