import { createContext, useContext, useRef, useEffect } from 'react'
import { ctx as configContext } from '../../../../../modules/config'
import Div from '../../../../../components/div'
import { useNavigate } from 'react-router-dom'
import Map from '@arcgis/core/Map'
import SceneView from '@arcgis/core/views/SceneView'
import GeoJSONLayer from '@arcgis/core/layers/GeoJSONLayer'
import esriConfig from '@arcgis/core/config'
import BaseElevationLayer from '@arcgis/core/layers/BaseElevationLayer'
import ElevationLayer from '@arcgis/core/layers/ElevationLayer'
import useTheme from '@mui/material/styles/useTheme'

// https://developers.arcgis.com/javascript/latest/visualization/3d-visualization/terrain-rendering/
const ExaggeratedElevationLayer = BaseElevationLayer.createSubclass({
  properties: {
    exaggeration: null,
  },

  load: function () {
    this._elevation = new ElevationLayer({
      url: 'https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/TopoBathy3D/ImageServer',
    })
    this.addResolvingPromise(this._elevation.load())
  },

  fetchTile: function (level, row, col, options) {
    return this._elevation.fetchTile(level, row, col, options).then(
      function (data) {
        var exaggeration = this.exaggeration
        for (var i = 0; i < data.values.length; i++) {
          data.values[i] = data.values[i] * exaggeration
        }
        return data
      }.bind(this)
    )
  },
})

export const context = createContext({})

const ESRI_BASEMAP = 'arcgis-oceans'

export default ({ children, models }) => {
  const theme = useTheme()
  const navigate = useNavigate()
  const { ESRI_API_KEY } = useContext(configContext)
  const ref = useRef(null)

  useEffect(() => {
    esriConfig.apiKey = ESRI_API_KEY

    const map = new Map({
      ground: {
        layers: [new ExaggeratedElevationLayer({ exaggeration: 1 })],
      },
      basemap: ESRI_BASEMAP,
      layers: [],
    })

    const view = new SceneView({
      map,
      container: ref.current,
      qualityProfile: 'medium',
      camera: {
        position: [31, -46, 1600000],
        heading: -20,
        tilt: 45,
      },
    })

    const layer = new GeoJSONLayer({
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
    })

    map.add(layer)

    view
      .when()
      .then(() => layer.when())
      .then(layer => view.whenLayerView(layer))
      .then(layerView => {
        view.on('pointer-down', async e => {
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

    window.esri = {
      map,
      view,
    }
  })

  return (
    <context.Provider value={{}}>
      <Div
        ref={ref}
        sx={{
          position: 'absolute',
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
        }}
      />
      {children}
    </context.Provider>
  )
}
