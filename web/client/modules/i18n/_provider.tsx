import { useContext, createContext, memo } from 'react'
import { ctx as siteSettingsContext } from '../site-settings'

const text = {
  '/home_h2': {
    en_ZA: 'Sustainable Ocean Modelling Initiative: A South African Approach',
    xh_ZA: 'Testing that the translations work',
  },
}

const t = (s, locale) => {
  return text[s]?.[locale] || text[s]?.en_ZA
}

export const ctx = createContext({ t })

const P = ({ locale, ...props }) => {
  console.log('hi', locale)

  return <ctx.Provider value={{ t, locale }} {...props} />
}

/**
 * Locale has to be forced during SSR
 */
export const Provider = ({ ...props }) => {
  const { locale } = useContext(siteSettingsContext)

  return <P locale={locale} {...props} />
}
