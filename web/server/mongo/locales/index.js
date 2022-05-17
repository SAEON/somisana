import collections from '../collections/index.js'
import locales from './_config.js'

export default async db => {
  for (const l of locales) {
    const { language, locale, ...other } = l

    await db
      .collection(collections.Locales.name)
      .findOneAndUpdate(
        { language },
        { $setOnInsert: { language, locale }, $set: { ...other } },
        { upsert: true, returnDocument: 'after' }
      )
  }
}
