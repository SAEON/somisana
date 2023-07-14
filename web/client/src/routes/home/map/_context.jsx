import { createContext, useContext, useMemo, useEffect, useState } from 'react'
import { context as configContext } from '../../../modules/config'
import maplibre from 'maplibre-gl'

export const context = createContext()

export default ({ container, children }) => {
  const [loaded, setLoaded] = useState(false)
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

  map.on('load', () => {
    setLoaded(true)
  })

  if (!loaded) {
    return null
  }

  // For debugging
  window.map = map

  return <context.Provider value={{ map }}>{children}</context.Provider>
}
