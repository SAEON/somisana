import { useContext, createContext } from 'react'
import { context as siteSettingsContext } from '../site-settings'

const text = {
  '/home_h2': {
    en: 'Sustainable Ocean Modelling Initiative: A South African Approach',
    xh: 'Testing that the translations work',
  },
  language: {
    en: 'Language',
  },
  'language-settings-blurb': {
    en: 'The SOMISANA i18n effort (content translation) will be a community-driven initiative - please submit an issue on GitHub to fast track this feature! (https://github.com/SAEON/somisana/issues)',
  },
  cookies: {
    en: 'Cookies',
  },
  theme: {
    en: 'Theme',
  },
  'Language translation': {
    en: 'Language translation',
  },
  'suggest-translation': {
    en: ' Please suggest a translation',
  },
}

const t = (s, language) => {
  if (!text[s]) {
    throw new Error(
      'Cannot translate non-existent text key. Please use an existing text key (or create a new one)'
    )
  }
  return {
    text: text[s][language] || text[s]?.en,
    missing: !text[s][language],
  }
}

export const context = createContext({ t })

const P = ({ language, ...props }) => {
  return <context.Provider value={{ t, language }} {...props} />
}

/**
 * language has to be forced during SSR
 */
export const Provider = ({ ...props }) => {
  const { language } = useContext(siteSettingsContext)

  return <P language={language} {...props} />
}
