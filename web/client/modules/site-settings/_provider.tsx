import { createContext, useCallback, useEffect, useMemo } from 'react'
import useCookieState, { getCookieValue } from '../../hooks/use-cookie-state'

interface SiteSettings {
  accepted: Boolean
  disableGoogleAnalytics?: Boolean
  locale: String
  updateSetting?: Function
}

const DEFAULT_SITE_SETTINGS: SiteSettings = {
  accepted: false,
  disableGoogleAnalytics: false,
  locale: undefined,
}

export const ctx = createContext(DEFAULT_SITE_SETTINGS)

const key = 'siteSettings'

export const Provider = ({ cookie, defaultLocale, ...props }) => {
  const cookies = typeof document === 'undefined' ? cookie : document.cookie

  const [settings, updateSettings] = useCookieState(key, {
    ...DEFAULT_SITE_SETTINGS,
    locale: defaultLocale,
    ...JSON.parse(
      getCookieValue({
        key,
        cookies: cookies,
        options: null,
        defaultValue: null,
      }) || '{}'
    ),
  })

  const _settings = useMemo(
    () => (typeof settings === 'string' ? JSON.parse(settings) : settings),
    [settings]
  )

  const updateSetting = useCallback(async (obj: SiteSettings) => {
    const newSettings: SiteSettings = { ..._settings, ...obj }
    updateSettings(newSettings)
  }, [])

  useEffect(() => {
    window['ga-disable-G-6ZM4ST1XCC'] = _settings.disableGoogleAnalytics
  }, [_settings.disableGoogleAnalytics])

  return <ctx.Provider value={{ ..._settings, updateSetting }} {...props} />
}
