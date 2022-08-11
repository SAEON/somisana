import { createContext, useEffect, useRef, useContext } from 'react'
import SceneView from '@arcgis/core/views/SceneView'
import Map from '@arcgis/core/Map'
import esriConfig from '@arcgis/core/config'
import VectorTileLayer from '@arcgis/core/layers/VectorTileLayer'
import FeatureLayer from '@arcgis/core/layers/FeatureLayer'
import BaseElevationLayer from '@arcgis/core/layers/BaseElevationLayer'
import ElevationLayer from '@arcgis/core/layers/ElevationLayer'
import { ctx as configContext } from '../../../modules/config'
import useTheme from '@mui/material/styles/useTheme'
import Div from '../../../components/div'

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

export const ctx = createContext(null)

export default ({ children }) => {
  const { TILESERV_BASE_URL, ESRI_API_KEY } = useContext(configContext)
  const theme = useTheme()
  const ref = useRef(null)
  const mapRef = useRef(null)
  // const ESRI_BASEMAP = 'arcgis-terrain'
  const ESRI_BASEMAP = 'arcgis-oceans'

  useEffect(() => {
    esriConfig.apiKey = ESRI_API_KEY

    const metadata = new VectorTileLayer({
      style: {
        id: 'metadata',
        version: 8,
        sources: {
          models: {
            type: 'vector',
            tiles: [`${TILESERV_BASE_URL}/public.metadata/{z}/{x}/{y}.pbf`],
          },
        },
        layers: [
          {
            id: 'model-metadata',
            type: 'fill',
            source: 'models',
            minzoom: 0,
            maxzoom: 24,
            'source-layer': 'public.metadata',
            paint: {
              'fill-color': theme.palette.primary.dark,
              'fill-opacity': 0.2,
              'fill-outline-color': theme.palette.primary.dark,
            },
          },
        ],
      },
    })

    const grid = new VectorTileLayer({
      url: 'https://basemaps.arcgis.com/arcgis/rest/services/World_Basemap_v2/VectorTileServer',
    })

    const gridOptions = {
      renderer: {
        type: 'simple',
        symbol: {
          color: theme.palette.grey[700],
          type: 'simple-line',
          style: 'dot',
        },
      },
      opacity: 0.75,
      labelingInfo: [
        {
          symbol: {
            type: 'text',
            color: 'green',
            font: {
              family: 'Playfair Display',
              size: 12,
              weight: 'bold',
            },
          },
          labelExpressionInfo: {
            expression: '$feature',
          },
        },
      ],
    }

    const map = new Map({
      ground: {
        layers: [new ExaggeratedElevationLayer({ exaggeration: 35 })],
      },
      basemap: ESRI_BASEMAP,
      layers: [
        new FeatureLayer({
          url: `https://services.arcgis.com/nGt4QxSblgDfeJn9/ArcGIS/rest/services/Graticule/FeatureServer/5`,
          ...gridOptions,
        }),
        new FeatureLayer({
          url: `https://services.arcgis.com/nGt4QxSblgDfeJn9/ArcGIS/rest/services/Graticule/FeatureServer/10`,
          ...gridOptions,
        }),
        metadata,
      ],
    })

    const view = new SceneView({
      map,
      container: ref.current,
      qualityProfile: 'high',
      viewingMode: 'local',
      camera: {
        position: [30, -45, 1200000],
        heading: -20,
        tilt: 50,
      },
      clippingArea: {
        xmax: 27.76671028137207,
        xmin: 24.820085525512695,
        ymax: -33.07335662841797,
        ymin: -34.85134506225586,
        spatialReference: {
          wkid: 4326,
        },
      },
    })

    window.esri = {
      map,
      view,
    }
  }, [])

  return (
    <ctx.Provider value={{ map: mapRef.current }}>
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
    </ctx.Provider>
  )
}
