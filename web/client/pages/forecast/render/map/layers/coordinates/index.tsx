import { useContext, useEffect, useCallback } from 'react'
import { context as mapContext } from '../../_context'
import { context as pageContext } from '../../../_context'
import { context as configContext } from '../../../../../../modules/config'
import { useTheme } from '@mui/material/styles'

const Render = ({
  map,
  setSelectedCoordinates,
  selectedCoordinates,
  modelid,
  TILESERV_BASE_URL,
}) => {
  const theme = useTheme()

  // Map event handlers
  const mouseenter = useCallback(() => (map.getCanvas().style.cursor = 'pointer'), [map])
  const mouseleave = useCallback(() => (map.getCanvas().style.cursor = ''), [map])
  const click = useCallback(
    ({ features }) =>
      setSelectedCoordinates(obj => {
        const featureId = features[0].id
        return { ...obj, [featureId]: !obj[featureId] }
      }),
    [map, setSelectedCoordinates]
  )

  // Add source, layer, and event handlers
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
        'circle-radius': ['case', ['boolean', ['feature-state', 'clicked'], false], 7, 2],
        'circle-stroke-width': ['interpolate', ['exponential', 1], ['zoom'], 7, 2, 18, 16],
        'circle-stroke-color': theme.palette.common.white,
        'circle-stroke-opacity': ['case', ['boolean', ['feature-state', 'clicked'], false], 0.8, 0],
        'circle-color': theme.palette.common.black,
        'circle-opacity': ['interpolate', ['exponential', 1], ['zoom'], 8, 0, 16, 1],
      },
    })

    map.on('click', 'coordinates', click)
    map.on('mouseenter', 'coordinates', mouseenter)
    map.on('mouseleave', 'coordinates', mouseleave)

    return () => {
      map.off('click', 'coordinates', click)
      map.off('mouseenter', 'coordinates', mouseenter)
      map.off('mouseleave', 'coordinates', mouseleave)
      map.removeLayer('coordinates')
      map.removeSource('coordinates')
    }
  }, [map, click, mouseenter, mouseleave])

  // Update the map layers on data change
  useEffect(() => {
    Object.entries(selectedCoordinates).forEach(([id, clicked]) => {
      map.setFeatureState(
        { source: 'coordinates', id, sourceLayer: 'public.coordinates' },
        { clicked }
      )
    })
  }, [selectedCoordinates])
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
