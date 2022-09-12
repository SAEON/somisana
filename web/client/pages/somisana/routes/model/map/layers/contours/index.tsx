import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_context'
import { context as modelContext } from '../../../_context'
import { ctx as configContext } from '../../../../../../../modules/config'
import useTheme from '@mui/material/styles/useTheme'
import { tricontour } from 'd3-tricontour'

export default () => {
  const theme = useTheme()
  const { API_HTTP } = useContext(configContext)
  const {
    map,
    model: { _id: modelid },
  } = useContext(mapContext)
  const { depth, timeStep } = useContext(modelContext)

  useEffect(() => {
    const _fetch = async () => {
      const response = await fetch(`${API_HTTP}/data`)
      const data = await response.json()
      const contours = tricontour()(data)
      console.log(contours)

      map.addSource('contours', {
        type: 'geojson',
        data: {
          type: 'FeatureCollection',
          features: [
            {
              type: 'Feature',
              geometry: {
                type: 'MultiPolygon',
                // These coordinates outline Maine.
                coordinates: [
                  [
                    [
                      [-67.13734, 45.13745],
                      [-66.96466, 44.8097],
                      [-68.03252, 44.3252],
                      [-69.06, 43.98],
                      [-70.11617, 43.68405],
                      [-70.64573, 43.09008],
                      [-70.75102, 43.08003],
                      [-70.79761, 43.21973],
                      [-70.98176, 43.36789],
                      [-70.94416, 43.46633],
                      [-71.08482, 45.30524],
                      [-70.66002, 45.46022],
                      [-70.30495, 45.91479],
                      [-70.00014, 46.69317],
                      [-69.23708, 47.44777],
                      [-68.90478, 47.18479],
                      [-68.2343, 47.35462],
                      [-67.79035, 47.06624],
                      [-67.79141, 45.70258],
                      [-67.13734, 45.13745],
                    ],
                  ],
                ],
              },
            },
          ],
        },
      })

      map.addLayer({
        id: 'contours',
        type: 'fill',
        source: 'contours',
        layout: {},
        paint: {
          'fill-color': '#0080ff', // blue color fill
          'fill-opacity': 0.5,
        },
      })
    }

    _fetch()
  }, [map, depth, timeStep])
}
