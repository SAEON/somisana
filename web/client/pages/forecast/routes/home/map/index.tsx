import MapProvider from './_context'
import CoordinatesLayer from './layers/coordinates'
import MetadataLayer from './layers/metadata'
import ContoursLayer from './layers/contours'

export default ({ container }) => {
  return (
    container && (
      <MapProvider container={container}>
        <MetadataLayer />
        <CoordinatesLayer />
        <ContoursLayer />
      </MapProvider>
    )
  )
}
