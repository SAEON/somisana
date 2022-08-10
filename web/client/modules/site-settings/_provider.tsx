import { createContext, useEffect, useState, useMemo } from 'react'
import c from 'cookie'

const COOKIE_KEY = 'SOMISANA_SITE_SETTINGS'

Date.prototype.addDays = function (days) {
  var date = new Date(this.valueOf())
  date.setDate(date.getDate() + days)
  return date
}

const ENCODE = { path: '/', expires: new Date().addDays(1000) }

interface SiteSettings {
  accepted?: Boolean
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
   * Load the cookie
   */
  const existingCookie = useMemo(
    () =>
      c.parse(cookie || typeof document === 'undefined' ? '' : document.cookie || '')?.[COOKIE_KEY],
    []
  )

  const {
    accepted = false,
    disableGoogleAnalytics = false,
    language = acceptLanguage,
  } = JSON.parse(existingCookie || '{}')

  /**
   * Set the initial settings state using stored cookie values
   */
  const [siteSettings, setSiteSettings]: [SiteSettings, Function] = useState({
    accepted,
    disableGoogleAnalytics,
    language: acceptLanguage,
  })

  /**
   * Whenever the siteSettings changes,
   * sync the state to a cookie
   */
  useEffect(() => {
    console.log(siteSettings)
    document.cookie = c.serialize(COOKIE_KEY, JSON.stringify(siteSettings), ENCODE)
  }, [siteSettings])

  const updateSetting = (obj: SiteSettings) => {
    setSiteSettings((s: SiteSettings) => ({ ...s, ...obj }))
  }

  /**
   * Client only
   *
   * This can only be done on the client, since the window
   * object is being updated
   */
  useEffect(() => {
    window['ga-disable-G-6ZM4ST1XCC'] = siteSettings.disableGoogleAnalytics
  })

  /**
   * Client only
   *
   * If the language in the cookie is not the same as the
   * accept language HTTP header, re-render the page with
   * the language override
   */
  useEffect(() => {
    if (language !== acceptLanguage) {
      setSiteSettings((s: SiteSettings) => ({ ...s, language }))
    }
  }, [])

  return <ctx.Provider value={{ ...siteSettings, updateSetting }} {...props} />
}
