import { useContext, useEffect, useMemo } from 'react'
import { context as mapContext } from '../../_context'
import { createPortal } from 'react-dom'
import { context as bandDataContext } from '../../../band-data/_context'
import { contours } from 'd3-contour'
import { Linear as Loading } from '../../../../../../../components/loading'
import { useTheme } from '@mui/material/styles'
import project from './_project'

const ContourLayer = ({ map, gridWidth, gridHeight, data, scaleMin, scaleMax, depth, color }) => {
  const theme = useTheme()
  const { id, json: points } = data.data

  const grid = useMemo(
    () => ({
      lng: points.map(([lng]) => lng),
      lat: points.map(([, lat]) => lat),
      temperature: points.map(([, , temperature]) => temperature),
    }),
    [points]
  )

  const polygons = useMemo(
    () =>
      contours()
        .thresholds(50)
        .size([gridWidth, gridHeight])(grid.temperature)
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
        }),
    [scaleMin, scaleMax]
  )

  const features = useMemo(
    () =>
      polygons.map(({ type, coordinates, value }) => {
        return {
          type: 'Feature',
          properties: { value, color: color(value) },
          geometry: {
            type,
            coordinates,
          },
        }
      }),
    [color, polygons]
  )

  if (!map.getSource(id)) {
    map.addSource(id, {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features,
      },
    })
  }

  if (!map.getLayer(id)) {
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
  }

  useEffect(() => {
    if (map.getSource(id)) {
      map.getSource(id).setData({
        type: 'FeatureCollection',
        features,
      })
    }
  }, [scaleMin, scaleMax])

  useEffect(() => {
    map.moveLayer(id)
    if (map.getLayer('coordinates')) map.moveLayer('coordinates')
  })

  useEffect(() => {
    console.log('add', depth)
    return () => {
      console.log('remove', depth)
    }
  }, [depth])
}

export default () => {
  const gql = useContext(bandDataContext)
  const {
    map,
    model: { gridWidth = 0, gridHeight = 0 } = {},
    scaleMin,
    scaleMax,
    depth,
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
      scaleMax={scaleMax}
      color={color}
      depth={depth}
    />
  )
}
