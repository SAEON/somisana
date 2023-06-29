import { createContext, useContext, useRef, useEffect, useMemo } from 'react'
import { context as configContext } from '../../../modules/config'
import Div from '../../../components/div'
import Map from '@arcgis/core/Map'
import SceneView from '@arcgis/core/views/SceneView'
import esriConfig from '@arcgis/core/config'
import ExaggeratedElevationLayer from './_exaggerated-elevation-layer'

export const context = createContext({})

export default ({ children }) => {
  const { ESRI_API_KEY, ESRI_BASEMAP } = useContext(configContext)
  const ref = useRef(null)

  esriConfig.apiKey = ESRI_API_KEY

  const map = useMemo(
    () =>
      new Map({
        ground: {
          layers: [new ExaggeratedElevationLayer({ exaggeration: 10 })],
        },
        basemap: ESRI_BASEMAP,
        layers: [],
      }),
    [ESRI_BASEMAP]
  )

  const view = useMemo(
    () =>
      new SceneView({
        map,
        qualityProfile: 'high',
        viewingMode: 'global',
        camera: {
          position: { x: 31, y: -46, z: 1600000 },
          heading: -20,
          tilt: 45,
        },
        spatialReference: {
          wkid: 3857,
        },
      }),
    [map]
  )

  useEffect(() => {
    view.container = ref.current
  })

  window.esri = {
    map,
    view,
  }

  return (
    <context.Provider value={{ map, view }}>
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
