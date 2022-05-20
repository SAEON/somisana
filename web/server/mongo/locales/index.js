import collections from '../collections/index.js'

const locales = [
  { locale: 'af_ZA', language: 'Afrikaans' },
  { locale: 'en_ZA', language: 'English' },
  { locale: 'nr_ZA', language: 'South Ndebele' },
  { locale: 'nso_ZA', language: 'Sesotho sa Leboa' },
  { locale: 'ss_ZA', language: 'Swati' },
  { locale: 'st_ZA', language: 'Southern Sotho' },
  { locale: 'tn_ZA', language: 'Tswana' },
  { locale: 'ts_ZA', language: 'Tsonga' },
  { locale: 've_ZA', language: 'Venda' },
  { locale: 'xh_ZA', language: 'isiXhosa' },
  { locale: 'zu_ZA', language: 'Zulu' },
]

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
