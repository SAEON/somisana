import { useContext, useEffect, useMemo } from 'react'
import { context as mapContext } from '../../_context'
import { context as modelContext } from '../../../_context'
import { ctx as configContext } from '../../../../../../../modules/config'
import { tricontour } from 'd3-tricontour'

export default () => {
  const { API_HTTP } = useContext(configContext)
  const { map } = useContext(mapContext)
  const { depth, timeStep } = useContext(modelContext)

  const id = useMemo(() => `contours${depth}${timeStep}`, [depth, timeStep])

  useEffect(() => {
    window.map = map
    const controller = new AbortController()
    const _fetch = async () => {
      const response = await fetch(
        `${API_HTTP}/data?time_step=${timeStep}&runid=1&depth=${depth}`,
        { signal: controller.signal }
      )
      const data = await response.json()
      const contours = tricontour()(data)

      const geojson = {
        type: 'FeatureCollection',
        features: contours.map(({ type, coordinates, value }) => ({
          type: 'Feature',
          properties: { value },
          geometry: {
            type,
            coordinates,
          },
        })),
      }

      const min = geojson.features[0].properties.value
      const max = geojson.features[geojson.features.length - 1].properties.value
      const range = max - min

      map.addSource(id, {
        type: 'geojson',
        data: geojson,
      })

      const exp = ['*', 255, ['/', ['-', ['get', 'value'], min], range]]

      map.addLayer(
        {
          id,
          type: 'fill',
          source: id,
          layout: {},
          paint: {
            'fill-color': ['rgba', ['+', 0, exp], 0, ['-', 255, exp], 1],
          },
        },
        'coordinates'
      )
    }

    if (map.getLayer(id)) {
      map.setLayoutProperty(id, 'visibility', 'visible')
    } else {
      _fetch()
    }

    return () => {
      if (map.getLayer(id)) {
        map.setLayoutProperty(id, 'visibility', 'none')
      } else {
        controller.abort()
      }
    }
  }, [map, depth, timeStep])
}
