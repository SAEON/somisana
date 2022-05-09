import { useState } from 'react'
import { createContext } from 'react'

const DEFAULT_SITE_SETTINGS = {}

export const ctx = createContext(DEFAULT_SITE_SETTINGS)

const Provider = (props: object) => {
  const [setSettings, updateSiteSettings] = useState(DEFAULT_SITE_SETTINGS)

  return <ctx.Provider value={{}} {...props} />
}

export default Provider
