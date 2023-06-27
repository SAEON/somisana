export default {
  name: 'locales',
  indices: [
    {
      index: 'language',
      options: {
        unique: false,
      },
    },
    {
      index: 'code',
      options: {
        unique: true,
      },
    },
  ],
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      description: 'Locale document',
      required: ['language', 'code', 'name'],
      properties: {
        language: {
          bsonType: 'string',
          description: 'Abbreviation of the language (for example, en=English)',
        },
        code: {
          bsonType: 'string',
          description: 'Locale short code',
        },
        name: {
          bsonType: 'string',
          description: 'Name of the locale language (in English)',
        },
      },
    },
  },
}
