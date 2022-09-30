import { useEffect, useRef, useContext } from 'react'
import maplibre from 'maplibre-gl'
import { ctx as configContext } from '../../modules/config'
import Div from '../../components/div'

export default () => {
  const ref = useRef(null)

  const { ESRI_API_KEY } = useContext(configContext)
  const basemapEnum = 'ArcGIS:ChartedTerritory'

  useEffect(() => {
    new maplibre.Map({
      container: ref.current,
      style: `https://basemaps-api.arcgis.com/arcgis/rest/services/styles/${basemapEnum}?type=style&token=${ESRI_API_KEY}`,
      zoom: 5,
      center: [24, -33],
      attributionControl: true,
    }).on('load', () => {})
  }, [])

  return <Div ref={ref} sx={{ width: '100%', height: '100%' }} />
}
