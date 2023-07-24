import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_context'
import { context as configContext } from '../../../../../modules/config'
import { useTheme } from '@mui/material/styles'

const Render = ({ map }) => {
  const theme = useTheme()

  // Add source, layer, and event handlers
  useEffect(() => {
    map.addSource('wms', {
      type: 'raster',
      tiles: [
        'https://thredds.somisana.ac.za/thredds/wms/data/somisana/algoa-bay/5-day-forecast/202307/20230723-hourly-avg-t3.nc?REQUEST=GetMap&VERSION=1.3.0&LAYERS=temp&STYLES=raster/psu-magma&&BBOX={bbox-epsg-3857}&CRS=EPSG:3857&WIDTH=256&HEIGHT=256&FORMAT=image/png&transparent=true&elevation=0&time=2023-07-23T01:30:00.000Z&COLORSCALERANGE=14.71,22.01&NUMCOLORBANDS=240',
      ],
      tileSize: 256,
    })
    

    map.addLayer(
      {
        id: 'wms',
        type: 'raster',
        source: 'wms',
      }
    )

    return () => {
      map.removeLayer('wms')
      map.removeSource('wms')
    }
  }, [map])
}

export default () => {
  const { REACT_APP_TILESERV_BASE_URL } = useContext(configContext)
  const { map } = useContext(mapContext)

  return <Render map={map} />
}
