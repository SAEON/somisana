import { createContext, useContext, useRef, useEffect } from 'react'
import { ctx as configContext } from '../../../../../modules/config'
import maplibre from 'maplibre-gl'
import Div from '../../../../../components/div'

export const context = createContext({})

export default ({ children }) => {
  const ref = useRef(null)
  const { ESRI_API_KEY } = useContext(configContext)

  const basemapEnum = 'ArcGIS:ChartedTerritory'

  useEffect(() => {
    const map = new maplibre.Map({
      container: ref.current,
      style: `https://basemaps-api.arcgis.com/arcgis/rest/services/styles/${basemapEnum}?type=style&token=${ESRI_API_KEY}`,
      zoom: 6,
      center: [24, -33],
    })

    map._container = ref.current
  })

  return (
    <context.Provider value={{}}>
      <Div
        sx={{
          position: 'absolute',
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
        }}
        ref={ref}
      />
      {children}
    </context.Provider>
  )
}
