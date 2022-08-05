import { createContext, useEffect, useRef, useContext } from 'react'
import MapView from '@arcgis/core/views/MapView'
import Map from '@arcgis/core/Map'
import esriConfig from '@arcgis/core/config'
import VectorTileLayer from '@arcgis/core/layers/VectorTileLayer'
import { ctx as configContext } from '../../../modules/config'
import useTheme from '@mui/material/styles/useTheme'
import Div from '../../../components/div'

export const ctx = createContext(null)

export default ({ children }) => {
  const { TILESERV_BASE_URL, ESRI_API_KEY } = useContext(configContext)
  const theme = useTheme()
  const ref = useRef(null)
  const mapRef = useRef(null)
  const ESRI_BASEMAP = 'arcgis-terrain'

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

    const map = new Map({
      basemap: ESRI_BASEMAP,
      layers: [metadata],
    })

    const view = new MapView({
      map,
      center: [25, -31],
      zoom: 6,
      container: ref.current,
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
