import { useEffect, memo, useContext, useMemo } from 'react'
import * as d3 from 'd3'
import { context as mapContext } from '../../../_context'
import { context as pageContext } from '../../../../_context'
// import * as tric from 'd3-tricontour'
import { contours } from 'd3-contour'
import { useTheme } from '@mui/material/styles'
import debounce from '../../../../../../../lib/debounce'
import { bilinearInterpolation } from '../lib/geospatial-fns'

function marginSquaresContours({
  thresholds,
  gridHeight,
  gridWidth,
  grid,
  selectedVariable,
  scaleMin,
  scaleMax,
  color,
}) {
  const polygons = contours()
    .thresholds(thresholds)
    .size([gridWidth, gridHeight])(grid[selectedVariable])
    .map(z => {
      return {
        ...z,
        value: z.value < scaleMin ? scaleMin : z.value > scaleMax ? scaleMax : z.value,
        coordinates: z.coordinates.map(polygon => {
          return polygon.map(ring =>
            ring.map(p => bilinearInterpolation(grid, gridHeight, gridWidth, p)).reverse()
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

  return { polygons, features }
}

// function meanderingTrianglesContours({ selectedVariable, thresholds, grid, color }) {
//   const polygons = tric
//     .tricontour()
//     .value(d => d[2][selectedVariable])
//     .thresholds(thresholds)(grid.values.filter(([, , v]) => v[selectedVariable]))

//   const features = polygons.map(({ type, coordinates, value }) => {
//     return {
//       type: 'Feature',
//       properties: { value, color: color(value) },
//       geometry: {
//         type,
//         coordinates,
//       },
//     }
//   })

//   return { polygons, features }
// }

const drawIsolines = color => [
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
  color,
]

const Render = memo(
  ({
    map,
    scaleMin,
    setScaleMin,
    scaleMax,
    setScaleMax,
    color,
    setTimeStep,
    animateTimeStep,
    selectedVariable,
    thresholds,
    grid,
    gridHeight,
    gridWidth,
    showIsolines,
  }) => {
    const theme = useTheme()
    const id = 'contour-layer'

    /**
     * Meandering triangles
     */
    // const { features } = useMemo(
    //   () => meanderingTrianglesContours({ selectedVariable, thresholds, grid, color }),
    //   [selectedVariable, thresholds, grid, color]
    // )

    /**
     * Marching squares
     */
    const { features } = useMemo(
      () =>
        marginSquaresContours({
          thresholds,
          gridHeight,
          gridWidth,
          grid,
          selectedVariable,
          scaleMin,
          scaleMax,
          color,
        }),
      [thresholds, gridHeight, gridWidth, grid, selectedVariable, scaleMin, scaleMax, color]
    )

    useEffect(() => {
      if (!scaleMin || !scaleMax) {
        const [min, max] = d3.extent(grid.values.map(([, , v]) => parseFloat(v[selectedVariable])))
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
        if (map.getLayer('mpas')) map.moveLayer('mpas')
        if (map.getLayer('coordinates')) map.moveLayer('coordinates')
      } else {
        map.getSource(id).setData({
          type: 'FeatureCollection',
          features,
        })
      }
    })

    useEffect(() => {
      map.setPaintProperty(
        id,
        'fill-outline-color',
        showIsolines ? drawIsolines(theme.palette.common.white) : 'transparent'
      )
    }, [showIsolines])

    if (animateTimeStep) {
      const frameTime = 100
      setTimeout(
        debounce(() => setTimeStep(t => (t >= 240 ? 1 : t + 1)), frameTime),
        frameTime
      )
    }
  }
)

export default ({ data, grid }) => {
  const { map } = useContext(mapContext)
  const {
    scaleMin,
    setScaleMin,
    setScaleMax,
    scaleMax,
    color,
    setTimeStep,
    animateTimeStep,
    selectedVariable,
    thresholds,
    showIsolines,
    model: { gridHeight, gridWidth },
  } = useContext(pageContext)

  return (
    <Render
      map={map}
      thresholds={thresholds}
      scaleMin={scaleMin}
      setScaleMin={setScaleMin}
      setScaleMax={setScaleMax}
      scaleMax={scaleMax}
      color={color}
      setTimeStep={setTimeStep}
      animateTimeStep={animateTimeStep}
      selectedVariable={selectedVariable}
      gridHeight={gridHeight}
      gridWidth={gridWidth}
      data={data}
      grid={grid}
      showIsolines={showIsolines}
    />
  )
}
