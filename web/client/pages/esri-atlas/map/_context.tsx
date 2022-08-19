import { createContext, useEffect, useRef, useContext, useMemo } from 'react'
import SceneView from '@arcgis/core/views/SceneView'
import Map from '@arcgis/core/Map'
import esriConfig from '@arcgis/core/config'
import FeatureLayer from '@arcgis/core/layers/FeatureLayer'
import OGCFeatureLayer from '@arcgis/core/layers/OGCFeatureLayer'
import { ctx as configContext } from '../../../modules/config'
import useTheme from '@mui/material/styles/useTheme'
import VectorTileLayer from '@arcgis/core/layers/VectorTileLayer'
import Div from '../../../components/div'
import ExaggeratedElevationLayer from '../../../modules/arcgis/exaggerated-elevation-layer'

export const ctx = createContext(null)

export default ({ model: { max_x, min_x, max_y, min_y }, children }) => {
  const { ESRI_API_KEY, ESRI_BASEMAP, TILESERV_BASE_URL } = useContext(configContext)
  const theme = useTheme()
  const ref = useRef(null)
  esriConfig.apiKey = ESRI_API_KEY

  const curvilinearGrid = new VectorTileLayer({
    style: {
      id: 'curvilinear-grid',
      version: 8,
      sources: {
        models: {
          type: 'vector',
          tiles: [`${TILESERV_BASE_URL}/public.values/{z}/{x}/{y}.pbf`],
        },
      },
      layers: [
        {
          id: 'model-metadata',
          type: 'circle',
          source: 'models',
          minzoom: 0,
          maxzoom: 24,
          'source-layer': 'public.values',
          paint: {
            'circle-radius': 2,
            'circle-opacity': 0.6,
            'circle-color': theme.palette.common.black,
          },
        },
      ],
    },
  })

  const gridOptions = useMemo(
    () => ({
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
    }),
    []
  )

  const xyzPoints = new OGCFeatureLayer({
    id: 'test',
    url: 'http://localhost:9000/',
    collectionId: 'public.values',
    objectIdField: 'id',
    // maxScale: 1,
    // minScale: 22,
    screenSizePerspectiveEnabled: true,
    elevationInfo: {
      mode: 'absolute-height',
      unit: 'meters',
    },
  })

  const map = useMemo(
    () =>
      new Map({
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
          // curvilinearGrid,
          xyzPoints,
        ],
      }),
    [gridOptions]
  )

  const view = useMemo(
    () =>
      new SceneView({
        map,
        qualityProfile: 'high',
        viewingMode: 'global',
        camera: {
          position: { x: 30, y: -45, z: 1400000 },
          heading: -20,
          tilt: 50,
        },
        clippingArea: {
          xmax: max_x,
          xmin: min_x,
          ymax: max_y,
          ymin: min_y,
          spatialReference: {
            wkid: 4326,
          },
        },
      }),
    [map, max_x, min_x, max_y, min_y]
  )

  useEffect(() => {
    view.container = ref.current
  }, [])

  window.esri = {
    map,
    view,
  }

  return (
    <ctx.Provider value={{}}>
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
