import { useContext, useEffect, memo } from 'react'
import { context as mapContext } from '../../_context'
import { context as pageContext } from '../../../_context'
import { ctx as configContext } from '../../../../../../../modules/config'
import { useTheme } from '@mui/material/styles'

const Render = memo(({ map, setSelectedCoordinate, modelid, TILESERV_BASE_URL }) => {
  const theme = useTheme()

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
})

export default () => {
  const { TILESERV_BASE_URL } = useContext(configContext)
  const { map } = useContext(mapContext)
  const { setSelectedCoordinate, model: { _id: modelid = 0 } = {} } = useContext(pageContext)

  return (
    <Render
      TILESERV_BASE_URL={TILESERV_BASE_URL}
      map={map}
      setSelectedCoordinate={setSelectedCoordinate}
      modelid={modelid}
    />
  )
}
