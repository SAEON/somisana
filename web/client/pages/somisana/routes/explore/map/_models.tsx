import { useContext, useMemo } from 'react'
import { context as mapContext } from './_context'
import GeoJSONLayer from '@arcgis/core/layers/GeoJSONLayer'
import useTheme from '@mui/material/styles/useTheme'
import { useNavigate } from 'react-router-dom'

export default ({ models }) => {
  console.log(models)
  const { map, view } = useContext(mapContext)
  const navigate = useNavigate()
  const theme = useTheme()

  const layer = useMemo(
    () =>
      new GeoJSONLayer({
        spatialReference: {
          wkid: 3857,
        },
        opacity: 0.3,
        outFields: ['_id', 'source'],
        renderer: {
          type: 'simple',
          symbol: {
            type: 'simple-fill',
            color: theme.palette.primary.dark,
            outline: {
              width: 1,
              color: 'white',
            },
          },
        },
        url: URL.createObjectURL(
          new Blob(
            [
              JSON.stringify({
                type: 'FeatureCollection',
                features: models.map(({ _id, id, envelope: geometry }) => {
                  return {
                    type: 'Feature',
                    id,
                    geometry,
                    properties: {
                      source: 'models',
                      _id,
                    },
                  }
                }),
              }),
            ],
            {
              type: 'application/json',
            }
          )
        ),
      }),
    []
  )

  map.add(layer)

  view
    .when()
    .then(() => layer.when())
    .then(layer => view.whenLayerView(layer))
    .then(layerView => {
      view.on('click', async e => {
        const test = await view.hitTest(e, { include: layer })
        if (test.results.length) {
          const graphic = test.results[0].graphic
          const attributes = graphic.attributes
          const { _id: id, source } = attributes
          if (source === 'models') {
            navigate(`/explore/${id}`)
          }
        }
      })

      let isPointer = false
      view.on('pointer-move', async e => {
        const test = await view.hitTest(e, { include: layer })
        if (test.results.length) {
          if (!isPointer) {
            view.container.setAttribute('style', 'cursor: pointer;')
            isPointer = true
          }
        } else {
          if (isPointer) {
            view.container.setAttribute('style', 'cursor: default;')
            isPointer = false
          }
        }
      })
    })

  return null
}
