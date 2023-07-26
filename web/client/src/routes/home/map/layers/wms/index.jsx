import { useContext, useEffect } from 'react'
import { context as mapContext } from '../../_context'

const regions = ['sw-cape','algoa-bay']

const Render = ({ map }) => {
  // Add source, layer, and event handlers
  useEffect(() => {
    map.addSource('wms', {
      type: 'raster',
      // https://nrt.cmems-du.eu/thredds/wms/cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m?request=GetCapabilities&service=WMS
      tiles: [
        'https://nrt.cmems-du.eu/thredds/wms/cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m?REQUEST=GetMap&VERSION=1.3.0&LAYERS=thetao&STYLES=boxfill/ncview&BBOX={bbox-epsg-3857}&CRS=EPSG:3857&WIDTH=256&HEIGHT=256&FORMAT=image/png&transparent=true',
      ],
      tileSize: 256,
    })

    map.addLayer({
      id: 'wms',
      type: 'raster',
      source: 'wms',
      paint: {
        'raster-opacity': 0.5,
      },
    })

    regions.forEach(async region => {
      const url = `https://mnemosyne.somisana.ac.za/somisana/${region}/5-day-forecast`
      const latestMonth = (await fetch(url, {
        method: 'GET',
        headers: {
          Accept: 'Application/json'
        }
      }).then(res => res.json())).filter(({isFile}) => !isFile).sort(({entry: a}, {entry: b}) => {
        // TODO
        return 1
      })
      console.log(latestMonth)
    })

    return () => {
      // map.removeLayer('wms')
      // map.removeSource('wms')
    }
  }, [map])
}

export default () => {
  const { map } = useContext(mapContext)

  return <Render map={map} />
}
