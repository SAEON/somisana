import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_context'
import { createPortal } from 'react-dom'
import { context as bandDataContext } from '../../../band-data/_context'
import { contours } from 'd3-contour'
import { Linear as Loading } from '../../../../../../../components/loading'
import { useTheme } from '@mui/material/styles'
import Div from '../../../../../../../components/div'
import project from './_project'
import * as d3 from 'd3'

export default () => {
  const theme = useTheme()
  const {
    map,
    model: { gridWidth, gridHeight },
  } = useContext(mapContext)
  const gql = useContext(bandDataContext)

  if (gql.error) {
    throw gql.error
  }

  useEffect(() => {
    const { data } = gql

    if (data) {
      const { id, json: points } = data.data

      if (map.getLayer(id)) {
        map.setLayoutProperty(id, 'visibility', 'visible')
      } else {
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

        const color = d3
          .scaleSequential(d3.interpolateMagma)
          .domain(d3.extent(polygons, d => d.value))

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
          'coordinates'
        )
      }
    }

    return () => {
      if (data) {
        const { id } = data.data
        if (map.getLayer(id)) {
          map.setLayoutProperty(id, 'visibility', 'none')
        }
      }
    }
  }, [gql])

  return createPortal(gql.loading ? <Loading /> : <Div />, map.getContainer())
}
