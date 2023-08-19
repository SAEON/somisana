import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_map-context'
import { context as configContext } from '../../../../../modules/config'
import { useTheme } from '@mui/material/styles'

const Render = ({ map, REACT_APP_TILESERV_BASE_URL }) => {
  const theme = useTheme()

  // Add source, layer, and event handlers
  useEffect(() => {
    map.addSource('coordinates', {
      type: 'vector',
      tiles: [
        `${REACT_APP_TILESERV_BASE_URL}/public.coordinates/{z}/{x}/{y}.pbf?filter=${encodeURIComponent(
          `bathymetry is not null`
        )}`,
      ],
      url: `${REACT_APP_TILESERV_BASE_URL}/public.coordinates.json`,
    })

    const MAX_ZOOM = 8
    const MIN_ZOOM = 12

    map.addLayer({
      id: 'coordinates',
      type: 'circle',
      source: 'coordinates',
      'source-layer': 'public.coordinates',
      paint: {
        'circle-radius': 1,
        'circle-color': theme.palette.common.black,
        'circle-opacity': [
          'interpolate',
          ['exponential', 1],
          ['zoom'],
          MAX_ZOOM,
          ['case', ['boolean', ['feature-state', 'clicked'], false], 0.8, 0.2],
          MIN_ZOOM,
          ['case', ['boolean', ['feature-state', 'clicked'], false], 0.8, 1],
        ],
      },
    })

    return () => {
      map.removeLayer('coordinates')
      map.removeSource('coordinates')
    }
  }, [
    map,
    REACT_APP_TILESERV_BASE_URL,
    theme.palette.common.black,
    theme.palette.common.white,
  ])

  // Make sure coordinates layer is always top
  useEffect(() => {
    if (map.getLayer('coordinates')) map.moveLayer('coordinates')
  })
}

export default ({ model }) => {
  const { REACT_APP_TILESERV_BASE_URL } = useContext(configContext)
  const { map } = useContext(mapContext)

  return (
    <Render
      model={model}
      REACT_APP_TILESERV_BASE_URL={REACT_APP_TILESERV_BASE_URL}
      map={map}
    />
  )
}
