import { useContext, useEffect, useMemo } from 'react'
import { context as mapContext } from '../../_context'
import { createPortal } from 'react-dom'
import { context as bandDataContext } from '../../../band-data/_context'
import { contours } from 'd3-contour'
import { Linear as Loading } from '../../../../../../../components/loading'
import { useTheme } from '@mui/material/styles'
import Div from '../../../../../../../components/div'
import Paper from '@mui/material/Paper'
import project from './_project'
import * as d3 from 'd3'
import Tooltip from '@mui/material/Tooltip'
import Typography from '@mui/material/Typography'
import invertColor, { padZero } from './_invert-color'
import Config from './config'

const ContourLayer = ({
  map,
  gridWidth,
  gridHeight,
  data,
  scaleMin,
  scaleMax,
  setScaleMin,
  setScaleMax,
}) => {
  const container = map.getContainer()
  const theme = useTheme()
  const { id, json: points } = data.data

  const grid = {
    lng: points.map(([lng]) => lng),
    lat: points.map(([, lat]) => lat),
    temperature: points.map(([, , temperature]) => temperature),
  }

  const polygons = useMemo(
    () =>
      contours()
        .thresholds(50)
        .size([gridWidth, gridHeight])(grid.temperature)
        .map(z => {
          return {
            ...z,
            value:
              scaleMin && z.value < scaleMin
                ? scaleMin
                : scaleMax && z.value > scaleMax
                ? scaleMax
                : z.value,
            coordinates: z.coordinates.map(polygon => {
              return polygon.map(ring =>
                ring.map(p => project(grid, gridHeight, gridWidth, p)).reverse()
              )
            }),
          }
        }),
    [scaleMin, scaleMax]
  )

  const color = useMemo(
    () => d3.scaleSequential(d3.interpolateMagma).domain(d3.extent(polygons, d => d.value)),
    [polygons]
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

  if (map.getSource(id)) {
    map.getSource(id).setData({
      type: 'FeatureCollection',
      features,
    })
  } else {
    map.addSource(id, {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features,
      },
    })
  }

  if (map.getLayer(id)) {
    map.moveLayer(id)
  } else {
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
  }

  if (map.getLayer('coordinates')) map.moveLayer('coordinates')

  return createPortal(
    <>
      {/* COLOR BAR */}
      <Paper
        sx={{
          my: theme => theme.spacing(8),
          mx: theme => theme.spacing(2),
          height: '100%',
          maxHeight: 'fill-available',
          position: 'absolute',
          left: 0,
          zIndex: 1,
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          overflow: 'auto',
        }}
      >
        <Config
          scaleMin={scaleMin}
          scaleMax={scaleMax}
          setScaleMin={setScaleMin}
          setScaleMax={setScaleMax}
        />
        {[...polygons].reverse().map(({ value }, i) => {
          return (
            <Tooltip key={i} placement="right-start" title={`${value} °C`}>
              <Div
                sx={{
                  backgroundColor: color(value),
                  flex: 1,
                  display: 'flex',
                  px: theme => theme.spacing(1),
                }}
              >
                {value.toFixed(0) == value && (
                  <Typography
                    sx={{
                      fontSize: '0.7rem',
                      fontWeight: 'bold',
                      color: invertColor(color(value), true),
                    }}
                    variant="overline"
                  >
                    {padZero(value)} °C
                  </Typography>
                )}
              </Div>
            </Tooltip>
          )
        })}
      </Paper>
    </>,
    container
  )
}

export default () => {
  const gql = useContext(bandDataContext)
  const {
    map,
    model: { gridWidth = 0, gridHeight = 0 } = {},
    scaleMin,
    scaleMax,
    setScaleMin,
    setScaleMax,
  } = useContext(mapContext)
  const container = map.getContainer()
  window.map = map

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
      setScaleMin={setScaleMin}
      setScaleMax={setScaleMax}
    />
  )
}
