import MapProvider from './_context'
import { useContext } from 'react'
import { context as modelContext } from '../_context'
import CoordinatesLayer from './layers/coordinates'
import MetadataLayer from './layers/metadata'
import ContoursLayer from './layers/contours'

export default ({ container }) => {
  const { model } = useContext(modelContext)

  return (
    container && (
      <MapProvider container={container} model={model}>
        <MetadataLayer />
        <CoordinatesLayer />
        <ContoursLayer />
      </MapProvider>
    )
  )
}
