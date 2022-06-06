import TileLayer from 'ol/layer/Tile'
import OSM from 'ol/source/OSM'

export default () =>
  new TileLayer({
    visible: true,
    source: new OSM({
      url: 'https://{a-c}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    }),
  })
