import { useEffect, useRef, useContext } from 'react'
import maplibre from 'maplibre-gl'
import { ctx as configContext } from '../../modules/config'
import Div from '../../components/div'

export default () => {
  const ref = useRef(null)

  const { ESRI_API_KEY, API_HTTP } = useContext(configContext)
  const basemapEnum = 'ArcGIS:ChartedTerritory'

  useEffect(() => {
    const map = new maplibre.Map({
      container: ref.current,
      style: `https://basemaps-api.arcgis.com/arcgis/rest/services/styles/${basemapEnum}?type=style&token=${ESRI_API_KEY}`,
      zoom: 5,
      center: [24, -33],
      attributionControl: true,
    })

    map.on('load', () => {
      map.addSource('test', {
        type: 'vector',
        tiles: [`${API_HTTP}/tiles/test/{z}/{x}/{y}.pbf`],
      })

      map.addLayer({
        id: 'test',
        type: 'circle',
        source: 'test',
        'source-layer': 'testLayer',
        paint: {
          'circle-radius': ['case', ['boolean', ['feature-state', 'click'], false], 7, 2],
          'circle-stroke-width': ['interpolate', ['exponential', 1], ['zoom'], 7, 2, 18, 16],
          'circle-stroke-color': 'white',
          'circle-stroke-opacity': ['case', ['boolean', ['feature-state', 'click'], false], 0.8, 0],
          'circle-color': 'black',
          'circle-opacity': ['interpolate', ['exponential', 1], ['zoom'], 8, 0, 16, 1],
        },
      })
    })
  }, [])

  return <Div ref={ref} sx={{ width: '100%', height: '100%' }} />
}
