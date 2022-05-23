export default {
  name: 'locales',
  gqlType: 'Locale',
  indices: [
    {
      index: 'language',
      options: {
        unique: true,
      },
    },
    {
      index: 'locale',
      options: {
        unique: true,
      },
    },
  ],
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      description: 'Locale document',
      required: ['locale', 'language'],
      properties: {
        language: {
          bsonType: 'string',
          description: 'Name of the locale language (in English)',
        },
        locale: {
          bsonType: 'string',
          description: 'locale short code',
        },
      },
    },
  },
}
