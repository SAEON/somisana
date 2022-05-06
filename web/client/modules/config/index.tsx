import { createContext, useState } from 'react'
import * as _config from './env/index.js'

if (_config.NODE_ENV !== 'production') {
  const ignore: string[] = []
  
  console.info(
    'Configuration',
    Object.fromEntries(
      Object.entries(_config)
        .filter(([field]) => !ignore.includes(field))
        .map(([field, value]) => [field, typeof value === 'function' ? value.toString() : value])
        .sort(([aKey], [bKey]) => {
          if (aKey > bKey) return 1
          if (bKey > aKey) return -1
          return 0
        })
    )
  )
}


export const ctx = createContext(_config)

const ConfigProvider = props => {
  const [config, setConfig] = useState(_config)

  return <ctx.Provider value={{ ...config, setConfig }} {...props} />
}

export default ConfigProvider
