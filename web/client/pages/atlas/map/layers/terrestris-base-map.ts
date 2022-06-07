import TileLayer from 'ol/layer/Tile'
import TileWMS from 'ol/source/TileWMS'

const URL = `https://ows.terrestris.de/osm-gray/service`

export default () =>
  new TileLayer({
    visible: true,
    source: new TileWMS({
      url: URL,
      params: {
        LAYERS: 'TOPO-WMS',
        TILED: false,
      },
      serverType: 'geoserver',
    }),
  })
