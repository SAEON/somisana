import { createContext, useContext, useMemo, useEffect, useState } from 'react'
import { ctx as configContext } from '../../../../../modules/config'
import { context as modelContext } from '../_context'
import maplibre from 'maplibre-gl'

export const context = createContext({})

export default ({ children, container }) => {
  const [load, setLoad] = useState(false)
  const { model, ...other } = useContext(modelContext)
  const { max_x = 0, max_y = 0, min_x = 0, min_y = 0 } = model || {}

  const { ESRI_API_KEY } = useContext(configContext)
  // const basemapEnum = 'ArcGIS:ChartedTerritory'
  const basemapEnum = 'ArcGIS:Oceans'

  const map = useMemo(
    () =>
      new maplibre.Map({
        container,
        style: `https://basemaps-api.arcgis.com/arcgis/rest/services/styles/${basemapEnum}?type=style&token=${ESRI_API_KEY}`,
        zoom: 5,
        center: [24, -33],
        attributionControl: true,
      }),
    []
  )

  useEffect(() => {
    map.on('load', () => {
      setLoad(true)
      map.fitBounds(
        [
          [min_x, max_y],
          [max_x, min_y],
        ],
        {
          linear: false,
          padding: 256,
          curve: 1,
          speed: 1,
        }
      )
    })
  }, [])

  if (!load) {
    return null
  }

  return <context.Provider value={{ map, model, ...other }}>{children}</context.Provider>
}
