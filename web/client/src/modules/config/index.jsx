import { createContext, useState } from 'react'
import * as _config from './env/index.js'

export const context = createContext(_config)

const ConfigProvider = props => {
  const [config, setConfig] = useState(_config)

  if (config.NODE_ENV !== 'production') {
    const ignore = []
    console.info(
      'Client configuration',
      Object.fromEntries(
        Object.entries(config)
          .filter(([field]) => !ignore.includes(field))
          .map(([field, value]) => [
            field,
            typeof value === 'function' ? value.toString() : value,
          ])
          .sort(([aKey], [bKey]) => {
            if (aKey > bKey) return 1
            if (bKey > aKey) return -1
            return 0
          })
      )
    )
  }

  return <context.Provider value={{ ...config, setConfig }} {...props} />
}

export default ConfigProvider
