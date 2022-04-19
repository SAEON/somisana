import { createContext } from 'react'
import * as config from './env/index.js'

export const context = createContext()

const ConfigProvider = props => {
  return <context.Provider value={config} {...props} />
}

export default ConfigProvider
