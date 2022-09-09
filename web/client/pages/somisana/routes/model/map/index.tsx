import MapProvider from './_context'
import { useContext, useState } from 'react'
import { context as modelContext } from '../_context'
import Div from '../../../../../components/div'
import CoordinatesLayer from './vector-layers/coordinates'
import MetadataLayer from './vector-layers/metadata'
import DepthControl from './controls/depth'
import TimeControl from './controls/time'

export default props => {
  const [ref, setRef] = useState(null)

  const { model } = useContext(modelContext)
  return (
    <>
      {ref && (
        <MapProvider container={ref} {...props} model={model}>
          <MetadataLayer />
          <CoordinatesLayer />
        </MapProvider>
      )}

      <Div
        id="a"
        sx={{
          display: 'flex',
          flex: 1,
        }}
      >
        <Div sx={{ display: 'flex', flex: 1, flexDirection: 'column', minHeight: 500 }}>
          <Div
            sx={{
              minHeight: 500,
            }}
            ref={el => setRef(el)}
          />
          <TimeControl />
        </Div>
        <DepthControl />
      </Div>
    </>
  )
}
