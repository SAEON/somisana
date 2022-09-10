import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_context'
import { ctx as configContext } from '../../../../../../../modules/config'
import { context as modelContext } from '../../../_context'
import useTheme from '@mui/material/styles/useTheme'

export default () => {
  const theme = useTheme()
  const { TILESERV_BASE_URL } = useContext(configContext)
  const {
    map,
    model: { _id: modelid },
  } = useContext(mapContext)
  const { setSelectedCoordinate } = useContext(modelContext)

  const sourceId = 'coordinates'

  useEffect(() => {
    map.addSource(sourceId, {
      type: 'vector',
      tiles: [
        `${TILESERV_BASE_URL}/public.coordinates/{z}/{x}/{y}.pbf?filter=${encodeURIComponent(
          `modelid=${modelid}
          and has_value=true`
        )}`,
      ],
      url: `${TILESERV_BASE_URL}/public.coordinates.json`,
    })

    map.addLayer({
      id: sourceId,
      type: 'circle',
      source: sourceId,
      'source-layer': 'public.coordinates',
      paint: {
        'circle-radius': ['case', ['boolean', ['feature-state', 'click'], false], 8, 2],
        'circle-stroke-width': 4,
        'circle-stroke-opacity': 0,
        'circle-color': [
          'case',
          ['boolean', ['feature-state', 'click'], false],
          theme.palette.grey[900],
          theme.palette.grey[600],
        ],
        'circle-opacity': ['case', ['boolean', ['feature-state', 'click'], false], 0.8, 0.4],
      },
    })

    let featureClickId = null
    map.on('mouseenter', sourceId, () => {
      map.getCanvas().style.cursor = 'pointer'
    })

    map.on('mouseleave', sourceId, () => {
      map.getCanvas().style.cursor = ''
    })

    map.on('click', sourceId, ({ features }) => {
      let oldId = featureClickId
      featureClickId = features[0].id
      map.setFeatureState(
        { source: sourceId, id: featureClickId, sourceLayer: 'public.coordinates' },
        { click: true }
      )
      if (oldId) {
        map.setFeatureState(
          { source: sourceId, id: oldId, sourceLayer: 'public.coordinates' },
          { click: false }
        )
      }
      if (oldId === featureClickId) {
        setSelectedCoordinate(null)
      } else {
        setSelectedCoordinate(featureClickId)
      }
    })
  }, [map])
}
