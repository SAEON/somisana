import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_context'
import { context as pageContext } from '../../../_context'
import { context as configContext } from '../../../../../modules/config'
import { useTheme } from '@mui/material/styles'

const Render = ({ map, showMPAs, TILESERV_BASE_URL }) => {
  const theme = useTheme()

  // Add source, layer, and event handlers
  useEffect(() => {
    if (!showMPAs) {
      if (map.getLayer('mpas')) map.removeLayer('mpas')
      if (map.getSource('mpas')) map.removeSource('mpas')
      return
    }
    map.addSource('mpas', {
      type: 'vector',
      tiles: [`${TILESERV_BASE_URL}/public.mpas/{z}/{x}/{y}.pbf`],
      url: `${TILESERV_BASE_URL}/public.mpas.json`,
      promoteId: 'ogc_fid',
    })

    map.addLayer({
      id: 'mpas',
      type: 'fill',
      source: 'mpas',
      'source-layer': 'public.mpas',
      paint: {
        'fill-outline-color': 'transparent',
        'fill-color': [
          'case',
          [
            'any',
            ['==', ['feature-state', 'hover'], true],
            ['==', ['feature-state', 'clicked'], true],
          ],
          theme.palette.primary.main,
          theme.palette.grey[100],
        ],
        'fill-opacity': 0.5,
      },
    })

    return () => {
      map.removeLayer('mpas')
      map.removeSource('mpas')
    }
  }, [map, showMPAs, TILESERV_BASE_URL, theme.palette.grey, theme.palette.primary.main])
}

export default () => {
  const { TILESERV_BASE_URL } = useContext(configContext)
  const { map } = useContext(mapContext)
  const { selectedMPAs, showMPAs } = useContext(pageContext)

  return (
    <Render
      TILESERV_BASE_URL={TILESERV_BASE_URL}
      map={map}
      showMPAs={showMPAs}
      selectedMPAs={selectedMPAs}
    />
  )
}
