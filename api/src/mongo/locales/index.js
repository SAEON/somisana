import collections from '../collections/index.js'

const locales = [
  { language: 'af', code: 'af_ZA', name: 'Afrikaans' },
  { language: 'en', code: 'en_ZA', name: 'English' },
  { language: 'nr', code: 'nr_ZA', name: 'South Ndebele' },
  { language: 'ns', code: 'nso_ZA', name: 'Sesotho sa Leboa' },
  { language: 'ss', code: 'ss_ZA', name: 'Swati' },
  { language: 'st', code: 'st_ZA', name: 'Sotho' },
  { language: 'tn', code: 'tn_ZA', name: 'Tswana' },
  { language: 'ts', code: 'ts_ZA', name: 'Tsonga' },
  { language: 've', code: 've_ZA', name: 'Venda' },
  { language: 'xh', code: 'xh_ZA', name: 'isiXhosa' },
  { language: 'zu', code: 'zu_ZA', name: 'Zulu' },
]

export default async db => {
  // Delete existing locales
  await db.collection(collections.Locales.name).deleteMany({})

  // Reinsert locales
  for (const l of locales) {
    const { name, code, ...other } = l
    await db
      .collection(collections.Locales.name)
      .findOneAndUpdate(
        { name },
        { $setOnInsert: { name, code }, $set: { ...other } },
        { upsert: true, returnDocument: 'after' }
      )
  }
}
