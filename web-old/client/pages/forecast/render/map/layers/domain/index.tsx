import { useContext, useEffect, memo } from 'react'
import { context as mapContext } from '../../_context'
import { context as pageContext } from '../../../_context'
import { context as configContext } from '../../../../../../modules/config'
import { useTheme } from '@mui/material/styles'

const Render = memo(({ TILESERV_BASE_URL, map, modelid, showDomain }) => {
  const theme = useTheme()

  useEffect(() => {
    if (!showDomain) {
      if (map.getLayer('metadata')) map.removeLayer('metadata')
      if (map.getSource('metadata')) map.removeSource('metadata')
      return
    }
    map.addSource('metadata', {
      type: 'vector',
      tiles: [
        `${TILESERV_BASE_URL}/public.models/{z}/{x}/{y}.pbf?filter=${encodeURIComponent(
          `id=${modelid}`
        )}`,
      ],
      url: `${TILESERV_BASE_URL}/public.models.json`,
      promoteId: 'id',
    })

    map.addLayer({
      id: 'metadata',
      type: 'line',
      source: 'metadata',
      'source-layer': 'public.models',
      paint: {
        'line-color': theme.palette.grey[900],
        'line-width': 1,
        'line-dasharray': [1, 1],
      },
    })

    return () => {
      map.removeLayer('metadata')
      map.removeSource('metadata')
    }
  }, [map, showDomain])
})

export default () => {
  const { TILESERV_BASE_URL } = useContext(configContext)
  const { map } = useContext(mapContext)
  const { model: { _id: modelid = 0 } = {}, showDomain } = useContext(pageContext)

  return (
    <Render
      map={map}
      modelid={modelid}
      TILESERV_BASE_URL={TILESERV_BASE_URL}
      showDomain={showDomain}
    />
  )
}
