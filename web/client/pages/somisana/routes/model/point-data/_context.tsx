import { createContext, useContext } from 'react'
import { context as modelContext } from '../_context'

export const context = createContext({})

export default ({ children }) => {
  const model = useContext(modelContext)

  return <context.Provider value={{ ...model }}>{children}</context.Provider>
}
