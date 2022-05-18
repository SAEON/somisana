import { createContext, useContext, useCallback, useEffect } from 'react'
import useLocalStorage from '../../hooks/use-local-storage'
import { ctx as configContext } from '../config'

interface SiteSettings {
  disableGoogleAnalytics?: Boolean
  updateSetting?: Function
}

const DEFAULT_SITE_SETTINGS: SiteSettings = {
  disableGoogleAnalytics: false,
}

export const ctx = createContext(DEFAULT_SITE_SETTINGS)

const Provider = (props: object) => {
  const { ORIGIN } = useContext(configContext)
  const [settings, updateSettings] = useLocalStorage(
    window?.location.origin || ORIGIN,
    DEFAULT_SITE_SETTINGS
  ) // TODO - probably needs to be cookie state so that it's accessible on the server

  const updateSetting = useCallback((obj: SiteSettings) => {
    updateSettings((settings: SiteSettings) => ({ ...settings, ...obj }))
  }, [])

  useEffect(() => {
    window['ga-disable-G-6ZM4ST1XCC'] = settings.disableGoogleAnalytics
  }, [settings.disableGoogleAnalytics])

  return <ctx.Provider value={{ ...settings, updateSetting }} {...props} />
}

export default Provider
