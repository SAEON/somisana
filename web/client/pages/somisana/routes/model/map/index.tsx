import MapProvider from './_context'
import { useContext, useState } from 'react'
import { context as modelContext } from '../_context'
import Div from '../../../../../components/div'
import ValuesLayer from './vector-layers/values'
import MetadataLayer from './vector-layers/metadata'
import TimeControl from './controls/time'

export default props => {
  const [ref, setRef] = useState(null)

  const { model } = useContext(modelContext)
  return (
    <>
      {ref && (
        <MapProvider container={ref} {...props} model={model}>
          <MetadataLayer />
          <ValuesLayer />
          <TimeControl />
        </MapProvider>
      )}
      <Div
        sx={{
          position: 'absolute',
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
        }}
        ref={el => setRef(el)}
      />
    </>
  )
}
