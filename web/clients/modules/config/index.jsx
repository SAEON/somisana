import { createContext } from "react";

export const context = createContext()

const ConfigProvider = props => {
  return <context.Provider value={{}} {...props} />
}

export default ConfigProvider