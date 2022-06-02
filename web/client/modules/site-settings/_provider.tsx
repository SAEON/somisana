import { createContext, useCallback, useEffect, useState } from 'react'
import { useCookieState } from 'use-cookie-state'
import c from 'cookie'

const COOKIE_KEY = 'SOMISANA_SITE_SETTINGS'

interface SiteSettings {
  accepted: Boolean
  disableGoogleAnalytics?: Boolean
  language?: String
  updateSetting?: Function
}

const DEFAULT_SITE_SETTINGS: SiteSettings = {
  accepted: false,
  disableGoogleAnalytics: false,
}

export const ctx = createContext(DEFAULT_SITE_SETTINGS)

export const Provider = ({ cookie, acceptLanguage, ...props }) => {
  /**
   * The site is always rendered according to the Accept-language
   * HTTP header. But a user can select a different language,
   * in which case on the client (not the server) the site
   * will be re-rendered in the preffered langauge. The 
   * preferred language is stored in the cookie as 'language'
   */
  const [language, setLanguage] = useState(acceptLanguage)

  /**
   * Site settings that need to be persisted
   */
  const [settings, updateSettings] = useCookieState(
    COOKIE_KEY,
    JSON.stringify({
      ...DEFAULT_SITE_SETTINGS,
      language,
    }),
    {
      decode: c.CookieParseOptions,
      encode: c.CookieSerializeOptions,
    }
  )

  const updateSetting = useCallback(async (obj: SiteSettings) => {
    const newSettings: SiteSettings = { ...JSON.parse(settings), ...obj }
    updateSettings(JSON.stringify(newSettings))
    if (newSettings.language) {
      setLanguage(newSettings.language)
    }
  }, [])

  /**
   * Client only
   *
   * This can only be done on the client, since the window
   * object is being updated
   */
  useEffect(() => {
    window['ga-disable-G-6ZM4ST1XCC'] = JSON.parse(settings).disableGoogleAnalytics
  }, [])

  /**
   * Client only
   *
   * Re-render the page in a user's preferred language,
   * if that prefferred language doesn't match their
   * browser's language setting
   */
  useEffect(() => {
    if (language !== JSON.parse(settings).language) {
      setLanguage(JSON.parse(settings).language)
    }
  }, [language])

  const { language: prefferedLanguage, ...userSettings } = JSON.parse(settings)

  return <ctx.Provider value={{ ...userSettings, language, updateSetting }} {...props} />
}
