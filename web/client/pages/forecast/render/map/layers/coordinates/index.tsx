import { useContext, useEffect, useCallback } from 'react'
import { context as mapContext } from '../../_context'
import { context as pageContext } from '../../../_context'
import { context as configContext } from '../../../../../../modules/config'
import { useTheme } from '@mui/material/styles'

const Render = ({ map, setSelectedCoordinates, modelid, TILESERV_BASE_URL }) => {
  const theme = useTheme()

  const mouseenter = useCallback(() => {
    map.getCanvas().style.cursor = 'pointer'
  }, [map])

  const mouseleave = useCallback(() => {
    map.getCanvas().style.cursor = ''
  }, [map])

  const click = useCallback(
    ({ features }) => {
      const featureId = features[0].id
      const featureState = map.getFeatureState({
        source: 'coordinates',
        id: featureId,
        sourceLayer: 'public.coordinates',
      })

      // This feature was clicked previously and should be removed
      if (featureState?.click) {
        setSelectedCoordinates(ids => ids.filter(id => id !== featureId))
        map.setFeatureState(
          { source: 'coordinates', id: featureId, sourceLayer: 'public.coordinates' },
          { click: false }
        )
      } else {
        // Otherwise this is a new feature click
        setSelectedCoordinates(ids => [...new Set([...ids, featureId])])
        map.setFeatureState(
          { source: 'coordinates', id: featureId, sourceLayer: 'public.coordinates' },
          { click: true }
        )
      }
    },
    [map, setSelectedCoordinates]
  )

  useEffect(() => {
    if (!map.getSource('coordinates')) {
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
    }

    if (map.getLayer('coordinates')) {
    } else {
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
    }

    map.on('click', 'coordinates', click)

    return () => {
      map.off('click', 'coordinates', click)
    }
  }, [map, click])

  useEffect(() => {
    map.on('mouseenter', 'coordinates', mouseenter)
    map.on('mouseleave', 'coordinates', mouseleave)

    return () => {
      map.off('mouseenter', 'coordinates', mouseenter)
      map.off('mouseleave', 'coordinates', mouseleave)
    }
  }, [map, mouseenter, mouseleave])
}

export default () => {
  const { TILESERV_BASE_URL } = useContext(configContext)
  const { map } = useContext(mapContext)
  const {
    setSelectedCoordinates,
    selectedCoordinates,
    model: { _id: modelid = 0 } = {},
  } = useContext(pageContext)

  return (
    <Render
      TILESERV_BASE_URL={TILESERV_BASE_URL}
      map={map}
      selectedCoordinates={selectedCoordinates}
      setSelectedCoordinates={setSelectedCoordinates}
      modelid={modelid}
    />
  )
}
