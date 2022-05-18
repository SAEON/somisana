import { createContext, useCallback, useEffect } from 'react'
import useLocalStorage from '../../hooks/use-local-storage'

interface SiteSettings {
  disableGoogleAnalytics: Boolean
  updateSetting: Function
}

const DEFAULT_SITE_SETTINGS: SiteSettings = {
  disableGoogleAnalytics: false,
  updateSetting: undefined,
}

export const ctx = createContext(DEFAULT_SITE_SETTINGS)

const Provider = (props: object) => {
  const [settings, updateSettings] = useLocalStorage(window.location.origin, DEFAULT_SITE_SETTINGS)

  const updateSetting = useCallback(obj => {
    updateSettings(settings => ({ ...settings, ...obj }))
  }, [])

  useEffect(() => {
    window['ga-disable-G-6ZM4ST1XCC'] = settings.disableGoogleAnalytics
  }, [settings.disableGoogleAnalytics])

  return <ctx.Provider value={{ ...settings, updateSetting }} {...props} />
}

export default Provider
