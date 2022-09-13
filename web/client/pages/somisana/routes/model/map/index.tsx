import MapProvider from './_context'
import { useContext } from 'react'
import { context as modelContext } from '../_context'
import CoordinatesLayer from './layers/coordinates'
import MetadataLayer from './layers/metadata'
import ContoursLayer from './layers/contours'

export default ({ divRef, ...props }) => {
  const { model } = useContext(modelContext)

  return (
    divRef && (
      <MapProvider container={divRef} {...props} model={model}>
        <MetadataLayer />
        <CoordinatesLayer />
        <ContoursLayer />
      </MapProvider>
    )
  )
}
