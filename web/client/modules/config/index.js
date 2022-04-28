import { createContext, useState } from 'react'
import * as _config from './env/index.js'

export const ctx = createContext()

const ConfigProvider = props => {
  const [config, setConfig] = useState(_config)

  return <ctx.Provider value={{ ...config, setConfig }} {...props} />
}

export default ConfigProvider
