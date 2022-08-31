import { createContext, useEffect } from 'react'
import { contours } from 'd3-contour'

export const context = createContext({})

export default ({ children }) => {
  useEffect(() => {
    ;(async () => {
      const url = new URL(`${window.location.protocol}//${window.location.host}/http/data`)
      url.searchParams.append('model', 'algoa-bay-forecast')
      url.searchParams.append('time_step', '1')
      url.searchParams.append('depth', '1')
      url.searchParams.append('run_date', '20220831')
      const req = await fetch(url, {
        method: 'GET',
      })
      const json = await req.json()
      console.log(json)

      console.log(contours)
    })()
  }, [])
  return <context.Provider value={{}}>{children}</context.Provider>
}
