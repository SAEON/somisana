import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_context'
import { ctx as configContext } from '../../../../../../../modules/config'
import useTheme from '@mui/material/styles/useTheme'

export default () => {
  const theme = useTheme()
  const { TILESERV_BASE_URL } = useContext(configContext)
  const {
    map,
    model: { _id: modelid },
  } = useContext(mapContext)

  useEffect(() => {
    map.addSource('metadata', {
      type: 'vector',
      tiles: [
        `${TILESERV_BASE_URL}/public.metadata/{z}/{x}/{y}.pbf?filter=${encodeURIComponent(
          `id=${modelid}`
        )}`,
      ],
      url: `${TILESERV_BASE_URL}/public.metadata.json`,
      promoteId: 'id',
    })

    map.addLayer({
      id: 'metadata',
      type: 'line',
      source: 'metadata',
      'source-layer': 'public.metadata',
      paint: {
        'line-color': theme.palette.grey[900],
      },
    })
  }, [map])
}
