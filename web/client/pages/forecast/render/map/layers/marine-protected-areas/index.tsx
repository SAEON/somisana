import { useContext, useEffect, useCallback } from 'react'
import { context as mapContext } from '../../_context'
import { context as configContext } from '../../../../../../modules/config'
import { useTheme } from '@mui/material/styles'

const Render = ({ map, modelid, TILESERV_BASE_URL }) => {
  const theme = useTheme()

  // Map event handlers
  const mouseenter = useCallback(
    ({ features }) => (map.getCanvas().style.cursor = 'pointer'),
    [map]
  )
  const mouseleave = useCallback(({ features }) => (map.getCanvas().style.cursor = ''), [map])

  // Add source, layer, and event handlers
  useEffect(() => {
    map.addSource('mpas', {
      type: 'vector',
      tiles: [`${TILESERV_BASE_URL}/public.mpas/{z}/{x}/{y}.pbf`],
      url: `${TILESERV_BASE_URL}/public.mpas.json`,
    })

    const MAX_ZOOM = 8
    const MIN_ZOOM = 18

    map.addLayer({
      id: 'mpas',
      type: 'fill',
      source: 'mpas',
      'source-layer': 'public.mpas',
      paint: {
        'fill-outline-color': theme.palette.primary.dark,
        'fill-color': theme.palette.primary.main,
        'fill-opacity': 0.5,
      },
    })

    map.on('mouseenter', 'mpas', mouseenter)
    map.on('mouseleave', 'mpas', mouseleave)

    return () => {
      map.off('mouseenter', 'mpas', mouseenter)
      map.off('mouseleave', 'mpas', mouseleave)
      map.removeLayer('mpas')
      map.removeSource('mpas')
    }
  }, [map, mouseenter, mouseleave])
}

export default () => {
  const { TILESERV_BASE_URL } = useContext(configContext)
  const { map } = useContext(mapContext)

  return <Render TILESERV_BASE_URL={TILESERV_BASE_URL} map={map} />
}
