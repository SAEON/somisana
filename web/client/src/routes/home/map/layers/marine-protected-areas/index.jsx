import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_map-context'
import { context as configContext } from '../../../../../modules/config'
import { useTheme } from '@mui/material/styles'

const Render = ({ map, REACT_APP_TILESERV_BASE_URL }) => {
  const theme = useTheme()

  // Add source, layer, and event handlers
  useEffect(() => {
    map.addSource('mpas', {
      type: 'vector',
      tiles: [`${REACT_APP_TILESERV_BASE_URL}/public.mpas/{z}/{x}/{y}.pbf`],
      url: `${REACT_APP_TILESERV_BASE_URL}/public.mpas.json`,
      promoteId: 'ogc_fid',
    })

    map.addLayer({
      id: 'mpas',
      type: 'fill',
      source: 'mpas',
      'source-layer': 'public.mpas',
      paint: {
        'fill-outline-color': theme.palette.common.white,
        'fill-color': theme.palette.common.black,
        'fill-opacity': 0.5,
      },
    })

    return () => {
      map.removeLayer('mpas')
      map.removeSource('mpas')
    }
  }, [map, REACT_APP_TILESERV_BASE_URL, theme.palette.common.black, theme.palette.common.white])
}

export default () => {
  const { REACT_APP_TILESERV_BASE_URL } = useContext(configContext)
  const { map } = useContext(mapContext)

  return (
    <Render
      REACT_APP_TILESERV_BASE_URL={REACT_APP_TILESERV_BASE_URL}
      map={map}
    />
  )
}
