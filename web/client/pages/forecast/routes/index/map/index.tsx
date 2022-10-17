import MapProvider from './_context'
import CoordinatesLayer from './layers/coordinates'
import MetadataLayer from './layers/metadata'
import VisualizationsLayer from './layers/visualizations'

export default ({ container }) => {
  return (
    container && (
      <MapProvider container={container}>
        <MetadataLayer />
        <CoordinatesLayer />
        <VisualizationsLayer />
      </MapProvider>
    )
  )
}
