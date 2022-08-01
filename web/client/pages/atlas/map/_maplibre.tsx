import { useEffect, useRef, useContext } from 'react'
import { ctx as configContext } from '../../../modules/config'
import Div from '../../../components/div'
import useTheme from '@mui/material/styles/useTheme'
import maplibre from 'maplibre-gl'

export default ({ Attribution }) => {
  const { TILESERV_BASE_URL, ESRI_API_KEY } = useContext(configContext)
  const theme = useTheme()
  const ref = useRef(null)

  useEffect(() => {
    const basemapEnum = 'ArcGIS:Oceans'

    const map = new maplibre.Map({
      container: ref.current,
      style: `https://basemaps-api.arcgis.com/arcgis/rest/services/styles/${basemapEnum}?type=style&token=${ESRI_API_KEY}`,
      center: [25, -31],
      zoom: 5.5,
    })

    map.on('load', () => {
      map.addSource('coordinates', {
        type: 'vector',
        tiles: [`${TILESERV_BASE_URL}/public.coordinates/{z}/{x}/{y}.pbf`],
        url: `${TILESERV_BASE_URL}/public.coordinates.json`,
      })

      map.addLayer({
        id: 'points',
        type: 'circle',
        source: 'coordinates',
        'source-layer': 'public.coordinates',
        paint: {
          'circle-color': theme.palette.primary.dark,
          'circle-opacity': 0.9,
          'circle-radius': 2,
        },
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
