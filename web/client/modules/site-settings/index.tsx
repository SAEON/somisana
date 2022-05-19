import { createContext, useContext, useCallback, useEffect, useMemo } from 'react'
import useCookieState, { getCookieValue } from '../../hooks/use-cookie-state'
import { ctx as configContext } from '../config'

interface SiteSettings {
  accepted: Boolean
  disableGoogleAnalytics?: Boolean
  updateSetting?: Function
}

const DEFAULT_SITE_SETTINGS: SiteSettings = {
  accepted: false,
  disableGoogleAnalytics: false,
}

export const ctx = createContext(DEFAULT_SITE_SETTINGS)

const Provider = ({ cookie, ...props }) => {
  const { ORIGIN } = useContext(configContext)

  const cookies = typeof document === 'undefined' ? cookie : document.cookie

  const [settings, updateSettings] = useCookieState(ORIGIN, {
    ...DEFAULT_SITE_SETTINGS,
    ...JSON.parse(
      getCookieValue({
        key: ORIGIN,
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

  const updateSetting = useCallback((obj: SiteSettings) => {
    const newSettings: SiteSettings = { ..._settings, ...obj }
    updateSettings(newSettings)
  }, [])

  useEffect(() => {
    window['ga-disable-G-6ZM4ST1XCC'] = _settings.disableGoogleAnalytics
  }, [_settings.disableGoogleAnalytics])

  return <ctx.Provider value={{ ..._settings, updateSetting }} {...props} />
}

export default Provider
