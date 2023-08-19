import Div from '../../../components/div'
import MapProvider from './_map-context'
import SaeonModels from './_saeon-models'
import MarineProtectedAreasLayer from './layers/marine-protected-areas'
import CmemsWMSLayer from './layers/cmems-wms'
import DomainsLayer from './layers/domains'
import CoordinatesLayer from './layers/coordinates'

export default ({ container }) => {
  return (
    container && (
      <Div>
        <MapProvider container={container}>
          <MarineProtectedAreasLayer />
          <CmemsWMSLayer />
          <DomainsLayer />
          <SaeonModels />
          <CoordinatesLayer />
        </MapProvider>
      </Div>
    )
  )
}
