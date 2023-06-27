import { createContext } from 'react'
import Div from '../../components/div'

export const context = createContext({})

export default ({ children }) => {
  // const image = '/bg/richard-horvath~cPccYbPrF-A~unsplash.jpg'
  const image = '/bg/joel-filipe~pfX-GsJMtDY~unsplash.jpg'
  const url = `url(${image})`
  return (
    <context.Provider value={{ url, image }}>
      <Div
        id="bg"
        sx={{
          position: 'fixed',
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          backgroundSize: 'cover',
          backgroundImage: url,
          zIndex: -1,
        }}
      />

      {children}
    </context.Provider>
  )
}
