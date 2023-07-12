import { useContext, useEffect, useCallback } from 'react'
import { context as mapContext } from '../../_context'
import { context as pageContext } from '../../../_context'
import { context as configContext } from '../../../../../modules/config'
import { useTheme } from '@mui/material/styles'

const Render = ({
  map,
  showCoordinates,
  setSelectedCoordinates,
  selectedCoordinates,
  modelid,
  REACT_APP_TILESERV_BASE_URL,
}) => {
  const theme = useTheme()

  // Map event handlers
  const mouseenter = useCallback(() => (map.getCanvas().style.cursor = 'pointer'), [map])
  const mouseleave = useCallback(() => (map.getCanvas().style.cursor = ''), [map])
  const click = useCallback(
    e => {
      e['bubble'] = 'no'
      const { features } = e
      setSelectedCoordinates(obj => {
        const featureId = features[0].id
        return { ...obj, [featureId]: !obj[featureId] }
      })
    },
    [setSelectedCoordinates]
  )

  // Add source, layer, and event handlers
  useEffect(() => {
    if (!showCoordinates) {
      if (map.getLayer('coordinates')) map.removeLayer('coordinates')
      if (map.getSource('coordinates')) map.removeSource('coordinates')
      setSelectedCoordinates({})
      return
    }

    map.addSource('coordinates', {
      type: 'vector',
      tiles: [
        `${REACT_APP_TILESERV_BASE_URL}/public.coordinates/{z}/{x}/{y}.pbf?filter=${encodeURIComponent(
          `modelid=${modelid}
          and bathymetry is not null`
        )}`,
      ],
      url: `${REACT_APP_TILESERV_BASE_URL}/public.coordinates.json`,
    })

    const MAX_ZOOM = 8
    const MIN_ZOOM = 18

    map.addLayer({
      id: 'coordinates',
      type: 'circle',
      source: 'coordinates',
      'source-layer': 'public.coordinates',
      paint: {
        'circle-radius': ['case', ['boolean', ['feature-state', 'clicked'], false], 7, 2],
        'circle-stroke-width': [
          'interpolate',
          ['exponential', 1],
          ['zoom'],
          MAX_ZOOM,
          ['case', ['boolean', ['feature-state', 'clicked'], false], 2, 2],
          MIN_ZOOM,
          ['case', ['boolean', ['feature-state', 'clicked'], false], 16, 1],
        ],
        'circle-stroke-color': theme.palette.common.white,
        'circle-stroke-opacity': [
          'interpolate',
          ['exponential', 1],
          ['zoom'],
          MAX_ZOOM,
          ['case', ['boolean', ['feature-state', 'clicked'], false], 0.8, 0],
          MIN_ZOOM,
          ['case', ['boolean', ['feature-state', 'clicked'], false], 0.8, 1],
        ],
        'circle-color': theme.palette.common.black,
        'circle-opacity': ['interpolate', ['exponential', 1], ['zoom'], MAX_ZOOM, 0, MIN_ZOOM, 1],
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
  }, [
    map,
    click,
    mouseenter,
    mouseleave,
    showCoordinates,
    REACT_APP_TILESERV_BASE_URL,
    modelid,
    setSelectedCoordinates,
    theme.palette.common.black,
    theme.palette.common.white,
  ])

  // Update the map layers on data change
  useEffect(() => {
    Object.entries(selectedCoordinates).forEach(([id, clicked]) => {
      map.setFeatureState(
        { source: 'coordinates', id, sourceLayer: 'public.coordinates' },
        { clicked }
      )
    })
  }, [selectedCoordinates, map])

  // Make sure coordinates layer is always top
  useEffect(() => {
    if (map.getLayer('coordinates')) map.moveLayer('coordinates')
  })
}

export default () => {
  const { REACT_APP_TILESERV_BASE_URL } = useContext(configContext)
  const { map } = useContext(mapContext)
  const {
    setSelectedCoordinates,
    selectedCoordinates,
    showCoordinates,
    model: { _id: modelid = 0 } = {},
  } = useContext(pageContext)

  return (
    <Render
      REACT_APP_TILESERV_BASE_URL={REACT_APP_TILESERV_BASE_URL}
      map={map}
      showCoordinates={showCoordinates}
      selectedCoordinates={selectedCoordinates}
      setSelectedCoordinates={setSelectedCoordinates}
      modelid={modelid}
    />
  )
}
