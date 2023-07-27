import { createContext, useContext, useMemo, memo, useEffect, useState } from 'react'
import { context as configContext } from '../../../modules/config'
import { context as modelContext } from '../_context'
import maplibre from 'maplibre-gl'

export const context = createContext({})

const P = memo(({ children, container, model }) => {
  const [load, setLoad] = useState(false)
  const { max_x = 0, max_y = 0, min_x = 0, min_y = 0 } = model || {}

  const { REACT_APP_ESRI_API_KEY } = useContext(configContext)
  const basemapEnum = 'ArcGIS:Oceans'

  const map = useMemo(
    () =>
      new maplibre.Map({
        container,
        style: `https://basemaps-api.arcgis.com/arcgis/rest/services/styles/${basemapEnum}?type=style&token=${REACT_APP_ESRI_API_KEY}`,
        zoom: 5,
        center: [24, -33],
        attributionControl: false,
        antialias: true,
      }),
    [REACT_APP_ESRI_API_KEY, container]
  )

  useEffect(() => {
    map.addControl(new maplibre.AttributionControl({ compact: false }))
  }, [map])

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
          padding: 64,
          curve: 1,
          speed: 0.5,
        }
      )
    })
  }, [map, max_x, max_y, min_x, min_y])

  if (!load) {
    return null
  }

  // For debugging
  window.map = map

  return <context.Provider value={{ map, model }}>{children}</context.Provider>
})

export default props => {
  const { model } = useContext(modelContext)
  return <P model={model} {...props} />
}
