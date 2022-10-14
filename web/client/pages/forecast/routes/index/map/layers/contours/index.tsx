import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_context'
import { createPortal } from 'react-dom'
import { context as bandDataContext } from '../../../band-data/_context'
import { contours } from 'd3-contour'
import { Linear as Loading } from '../../../../../../../components/loading'
import { useTheme } from '@mui/material/styles'
import project from './_project'
import * as d3 from 'd3'

const ContourLayer = ({
  map,
  gridWidth,
  gridHeight,
  data,
  scaleMin,
  setScaleMin,
  scaleMax,
  setScaleMax,
  color,
  setTimeStep,
  animateTimeStep,
  selectedVariable,
}) => {
  const theme = useTheme()
  const { id, json: points } = data.data

  const grid = points.reduce(
    (a, c) => {
      const [lng, lat, temperature, salinity, u, v] = c
      a.lng.push(lng)
      a.lat.push(lat)
      a.temperature.push(temperature)
      a.salinity.push(salinity)
      a.u.push(u)
      a.v.push(v)
      return a
    },
    {
      lng: [],
      lat: [],
      temperature: [],
      salinity: [],
      u: [],
      v: [],
    }
  )

  const polygons = contours()
    .thresholds(50)
    .size([gridWidth, gridHeight])(grid[selectedVariable])
    .map(z => {
      return {
        ...z,
        value: z.value < scaleMin ? scaleMin : z.value > scaleMax ? scaleMax : z.value,
        coordinates: z.coordinates.map(polygon => {
          return polygon.map(ring =>
            ring.map(p => project(grid, gridHeight, gridWidth, p)).reverse()
          )
        }),
      }
    })

  const features = polygons.map(({ type, coordinates, value }) => {
    return {
      type: 'Feature',
      properties: { value, color: color(value) },
      geometry: {
        type,
        coordinates,
      },
    }
  })

  useEffect(() => {
    if (!scaleMin || !scaleMax) {
      const [min, max] = d3.extent(grid[selectedVariable]).map(v => parseFloat(v))
      setScaleMin(min)
      setScaleMax(max)
    }
  })

  useEffect(() => {
    map.addSource(id, {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features,
      },
    })

    map.addLayer({
      id,
      type: 'fill',
      source: id,
      layout: {},
      paint: {
        'fill-color': ['get', 'color'],
        'fill-outline-color': [
          'step',
          ['zoom'],
          ['rgba', 255, 255, 255, 0],
          6,
          ['rgba', 255, 255, 255, 0.1],
          8,
          ['rgba', 255, 255, 255, 0.2],
          10,
          ['rgba', 255, 255, 255, 0.3],
          12,
          ['rgba', 255, 255, 255, 0.5],
          14,
          ['rgba', 255, 255, 255, 0.75],
          16,
          theme.palette.common.white,
        ],
      },
    })

    map.moveLayer(id)
    if (map.getLayer('coordinates')) map.moveLayer('coordinates')

    return () => {
      map.removeLayer(id)
      map.removeSource(id)
    }
  })

  if (animateTimeStep) {
    setTimeout(() => setTimeStep(t => (t >= 240 ? 1 : t + 1)), 1000)
  }
}

export default () => {
  const gql = useContext(bandDataContext)
  const {
    map,
    model: { gridWidth = 0, gridHeight = 0 } = {},
    scaleMin,
    setScaleMin,
    scaleMax,
    setScaleMax,
    setTimeStep,
    animateTimeStep,
    selectedVariable,
    color,
  } = useContext(mapContext)
  const container = map.getContainer()

  if (gql.error) {
    throw gql.error
  }

  if (gql.loading) {
    return createPortal(<Loading sx={{ top: 0 }} />, container)
  }

  return (
    <ContourLayer
      map={map}
      gridWidth={gridWidth}
      gridHeight={gridHeight}
      data={gql.data}
      scaleMin={scaleMin}
      setScaleMin={setScaleMin}
      setScaleMax={setScaleMax}
      scaleMax={scaleMax}
      color={color}
      setTimeStep={setTimeStep}
      animateTimeStep={animateTimeStep}
      selectedVariable={selectedVariable}
    />
  )
}
