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

  const sourceId = 'coordinates'

  useEffect(() => {
    map.addSource(sourceId, {
      type: 'vector',
      tiles: [
        `${TILESERV_BASE_URL}/public.somisana_model_coordinates/{z}/{x}/{y}.pbf?mid=${modelid}`,
      ],
      url: `${TILESERV_BASE_URL}/public.somisana_model_coordinates.json`,
    })

    map.addLayer({
      id: sourceId,
      type: 'circle',
      source: sourceId,
      'source-layer': 'default',
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
        'circle-opacity': ['case', ['boolean', ['feature-state', 'click'], false], 1, 0.3],
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
        { source: sourceId, id: featureClickId, sourceLayer: 'default' },
        { click: true }
      )
      if (oldId) {
        map.setFeatureState(
          { source: sourceId, id: oldId, sourceLayer: 'default' },
          { click: false }
        )
      }
    })
  }, [map])
}
