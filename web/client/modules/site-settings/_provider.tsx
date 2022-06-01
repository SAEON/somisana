import { createContext, useCallback, useEffect } from 'react'
import { useCookieState } from 'use-cookie-state'

interface SiteSettings {
  accepted: Boolean
  disableGoogleAnalytics?: Boolean
  language?: String
  updateSetting?: Function,
}

const DEFAULT_SITE_SETTINGS: SiteSettings = {
  accepted: false,
  disableGoogleAnalytics: false,
}

export const ctx = createContext(DEFAULT_SITE_SETTINGS)

const COOKIE_KEY = 'SOMISANA_SITE_SETTINGS'

export const Provider = ({ cookie, acceptLanguage, ...props }) => {
  const [settings, updateSettings] = useCookieState(COOKIE_KEY, (a) => {
    console.log('a', a)
    return JSON.stringify({
      ...DEFAULT_SITE_SETTINGS,
      language: acceptLanguage,
    })
  })



  const updateSetting = useCallback(async (obj: SiteSettings) => {
    const newSettings: SiteSettings = { ...JSON.parse(settings), ...obj }
    updateSettings(JSON.stringify(newSettings))
  }, [])

  // Client only
  useEffect(() => {
    window['ga-disable-G-6ZM4ST1XCC'] = JSON.parse(settings).disableGoogleAnalytics
  }, [])

  // // Client only
  // useEffect(() => {
  //   updateSetting({language})
  // }, [])

  console.log('settings', settings)

  return <ctx.Provider value={{ ...JSON.parse(settings), updateSetting }} {...props} />
}
