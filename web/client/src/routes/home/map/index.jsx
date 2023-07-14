import Div from '../../../components/div'
import MapProvider from './_context'
import MarineProtectedAreasLayer from './layers/marine-protected-areas'
import DomainsLayer from './layers/domains'

export default ({ container }) => {
  return (
    container && (
      <Div>
        <MapProvider container={container}>
          <MarineProtectedAreasLayer />
          <DomainsLayer />
        </MapProvider>
      </Div>
    )
  )
}
