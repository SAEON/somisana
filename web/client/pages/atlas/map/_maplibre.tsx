import { useEffect, useRef, useContext } from 'react'
import { ctx as configContext } from '../../../modules/config'
import Div from '../../../components/div'
import useTheme from '@mui/material/styles/useTheme'
import maplibre from 'maplibre-gl'

export default ({ Attribution }) => {
  const { TILESERV_BASE_URL, ESRI_API_KEY, NODE_ENV } = useContext(configContext)
  const theme = useTheme()
  const ref = useRef(null)

  useEffect(() => {
    const basemapEnum = 'ArcGIS:Terrain'

    const map = new maplibre.Map({
      container: ref.current,
      style: `https://basemaps-api.arcgis.com/arcgis/rest/services/styles/${basemapEnum}?type=style&token=${ESRI_API_KEY}`,
      center: [25, -31],
      zoom: 5.5,
    })

    if (NODE_ENV !== 'production') {
      window.map = map
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

      map.on('mouseleave', 'models', ({ features }) => {
        map.getCanvas().style.cursor = ''
        map.setFeatureState(
          { source: 'metadata', id: featureHoveredId, sourceLayer: 'public.metadata' },
          { hover: false }
        )
      })
    })
  }, [])

  return (
    <Div
      ref={ref}
      sx={{
        position: 'absolute',
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
      }}
    >
      <Attribution />
    </Div>
  )
}
