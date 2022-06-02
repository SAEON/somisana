import { useContext, createContext, memo } from 'react'
import { ctx as siteSettingsContext } from '../site-settings'

const text = {
  '/home_h2': {
    en: 'Sustainable Ocean Modelling Initiative: A South African Approach',
    xh: 'Testing that the translations work',
  },
}

const t = (s, language) => {
  return text[s]?.[language] || text[s]?.en
}

export const ctx = createContext({ t })

const P = ({ language, ...props }) => {
  return <ctx.Provider value={{ t, language }} {...props} />
}

/**
 * language has to be forced during SSR
 */
export const Provider = ({ ...props }) => {
  const { language } = useContext(siteSettingsContext)

  return <P language={language} {...props} />
}
