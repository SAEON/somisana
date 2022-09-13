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

  useEffect(() => {
    map.addSource('coordinates', {
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
      id: 'coordinates',
      type: 'circle',
      source: 'coordinates',
      'source-layer': 'public.coordinates',

      paint: {
        'circle-radius': ['case', ['boolean', ['feature-state', 'click'], false], 7, 2],
        'circle-stroke-width': ['interpolate', ['exponential', 1], ['zoom'], 7, 2, 18, 16],
        'circle-stroke-color': theme.palette.common.white,
        'circle-stroke-opacity': ['case', ['boolean', ['feature-state', 'click'], false], 0.8, 0],
        'circle-color': theme.palette.common.black,
        'circle-opacity': ['interpolate', ['exponential', 1], ['zoom'], 8, 0, 16, 1],
      },
    })

    let featureClickId = null
    map.on('mouseenter', 'coordinates', () => {
      map.getCanvas().style.cursor = 'pointer'
    })

    map.on('mouseleave', 'coordinates', () => {
      map.getCanvas().style.cursor = ''
    })

    map.on('click', 'coordinates', ({ features }) => {
      let oldId = featureClickId
      featureClickId = features[0].id
      map.setFeatureState(
        { source: 'coordinates', id: featureClickId, sourceLayer: 'public.coordinates' },
        { click: true }
      )
      if (oldId) {
        map.setFeatureState(
          { source: 'coordinates', id: oldId, sourceLayer: 'public.coordinates' },
          { click: false }
        )
      }
      if (oldId === featureClickId) {
        setSelectedCoordinate(null)
        featureClickId = null
      } else {
        setSelectedCoordinate(featureClickId)
      }
    })
  }, [map])
}
