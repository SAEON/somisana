import { createContext, useEffect, useRef, useContext } from 'react'
import { ctx as configContext } from '../../../modules/config'
import useTheme from '@mui/material/styles/useTheme'
import Div from '../../../components/div'
import maplibre from 'maplibre-gl'

export const ctx = createContext(null)

const ESRI_BASEMAP = 'ArcGIS:ChartedTerritory'

export default ({ children }) => {
  const { TILESERV_BASE_URL, ESRI_API_KEY } = useContext(configContext)
  const theme = useTheme()
  const ref = useRef(null)
  const mapRef = useRef(null)

  useEffect(() => {
    const map = new maplibre.Map({
      container: ref.current,
      style: `https://basemaps-api.arcgis.com/arcgis/rest/services/styles/${ESRI_BASEMAP}?type=style&token=${ESRI_API_KEY}`,
      center: [25, -30],
      zoom: 5,
      attributionControl: true,
    })

    window.maplibre = {
      map,
    }

    map.on('load', () => {
      map.addSource('metadata', {
        type: 'vector',
        tiles: [`${TILESERV_BASE_URL}/public.metadata/{z}/{x}/{y}.pbf`],
        url: `${TILESERV_BASE_URL}/public.metadata.json`,
        promoteId: 'id',
      })

      map.addLayer({
        id: 'models',
        type: 'fill',
        source: 'metadata',
        'source-layer': 'public.metadata',
        paint: {
          'fill-color': theme.palette.primary.dark,
          'fill-opacity': ['case', ['boolean', ['feature-state', 'hover'], false], 0.6, 0.2],
          'fill-outline-color': theme.palette.primary.dark,
        },
      })

      let featureHoveredId = null
      map.on('mouseenter', 'models', ({ features }) => {
        featureHoveredId = features[0].id
        map.getCanvas().style.cursor = 'pointer'
        map.setFeatureState(
          { source: 'metadata', id: featureHoveredId, sourceLayer: 'public.metadata' },
          { hover: true }
        )
      })

      map.on('mouseleave', 'models', () => {
        map.getCanvas().style.cursor = ''
        map.setFeatureState(
          { source: 'metadata', id: featureHoveredId, sourceLayer: 'public.metadata' },
          { hover: false }
        )
      })

      map.on('click', 'models', ({ features: [feature] }) => {
        const { min_x, min_y, max_x, max_y } = feature.properties
        map.fitBounds(
          [
            [min_x, max_y],
            [max_x, min_y],
          ],
          {
            linear: false,
            padding: 48,
            curve: 1,
            speed: 1.5,
          }
        )
      })
    })
  }, [])

  return (
    <ctx.Provider value={{ map: mapRef.current }}>
      <Div ref={ref} sx={{ display: 'flex', flexGrow: 1 }} />
      {children}
    </ctx.Provider>
  )
}
