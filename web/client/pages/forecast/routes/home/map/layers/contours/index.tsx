import { useContext, useEffect, useState } from 'react'
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

const cache = {}

const ContourLayer = ({ map, gridWidth, gridHeight, data }) => {
  const [scaleMin, setScaleMin] = useState(null)
  const [scaleMax, setScaleMax] = useState(null)
  const container = map.getContainer()
  const theme = useTheme()
  const { id, json: points } = data.data

  if (!map.getLayer(id)) {
    const grid = {
      lng: points.map(([lng]) => lng),
      lat: points.map(([, lat]) => lat),
      temperature: points.map(([, , temperature]) => temperature),
    }

    const polygons = contours()
      .thresholds(50)
      .size([gridWidth, gridHeight])(grid.temperature)
      .map(z => ({
        ...z,
        coordinates: z.coordinates.map(polygon =>
          polygon.map(ring => ring.map(p => project(grid, gridHeight, gridWidth, p)).reverse())
        ),
      }))

    const color = d3.scaleSequential(d3.interpolateMagma).domain(d3.extent(polygons, d => d.value))

    map.addSource(id, {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features: polygons.map(({ type, coordinates, value }) => {
          return {
            type: 'Feature',
            properties: { value, color: color(value) },
            geometry: {
              type,
              coordinates,
            },
          }
        }),
      },
    })

    map.addLayer(
      {
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
      },
      map.getLayer('coordinates') ? 'coordinates' : undefined
    )

    cache[id] = {
      polygons,
      color,
    }
  }

  const { polygons, color } = cache[id]

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
        {[...polygons].reverse().map(({ value }, i) => (
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
        ))}
      </Paper>
    </>,
    container
  )
}

export default () => {
  const gql = useContext(bandDataContext)
  const { map, model: { gridWidth = 0, gridHeight = 0 } = {} } = useContext(mapContext)
  const container = map.getContainer()

  useEffect(() => {
    const id = gql.data?.data.id

    if (map.getLayer(id)) {
      map.setLayoutProperty(id, 'visibility', 'visible')
    }

    return () => {
      if (id && map.getLayer(id)) {
        map.setLayoutProperty(id, 'visibility', 'none')
      }
    }
  })

  if (gql.error) {
    throw gql.error
  }

  if (gql.loading) {
    return createPortal(<Loading sx={{ top: 0 }} />, container)
  }

  return <ContourLayer map={map} gridWidth={gridWidth} gridHeight={gridHeight} data={gql.data} />
}
