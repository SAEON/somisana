import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_context'
import { useTheme } from '@mui/material/styles'

const Render = ({ map }) => {
  const theme = useTheme()

  // Add source, layer, and event handlers
  useEffect(() => {
    map.addSource('wms', {
      type: 'raster',
      tiles: [
        'https://nrt.cmems-du.eu/thredds/wms/cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m?REQUEST=GetMap&VERSION=1.3.0&LAYERS=thetao&STYLES=boxfill/ncview&BBOX={bbox-epsg-3857}&CRS=EPSG:3857&WIDTH=256&HEIGHT=256&FORMAT=image/png&transparent=true&NUMCOLORBANDS=120',
      ],
      tileSize: 256,
    })
    

    map.addLayer(
      {
        id: 'wms',
        type: 'raster',
        source: 'wms',
        paint: {
          'raster-opacity': 0.5
        }
      }
    )

    return () => {
      map.removeLayer('wms')
      map.removeSource('wms')
    }
  }, [map])
}

export default () => {
  const { map } = useContext(mapContext)

  return <Render map={map} />
}
