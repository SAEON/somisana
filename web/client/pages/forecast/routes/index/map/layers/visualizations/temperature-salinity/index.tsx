import { useEffect, memo } from 'react'
import * as d3 from 'd3'
import { contours } from 'd3-contour'
import { useTheme } from '@mui/material/styles'
import project from '../lib/project-coordinates'

export default memo(
  ({
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
    grid,
  }) => {
    const theme = useTheme()
    const { id: _id } = data

    const id = `${selectedVariable}${_id}`

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
      if (!map.getSource(id)) {
        map.addSource(id, {
          type: 'geojson',
          data: {
            type: 'FeatureCollection',
            features,
          },
        })
      }

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
)
