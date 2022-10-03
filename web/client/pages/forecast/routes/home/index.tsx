import { Suspense, useState, useEffect } from 'react'
import { Linear as Loading } from '../../../../components/loading'
import Div from '../../../../components/div'
import Paper from '@mui/material/Paper'
import ModelProvider from './_context'
import BandDataProvider from './band-data'
import DepthControl from './controls/depth'
import TimeControl from './controls/time'
import Map from './map'

export default ({ modelid = undefined }) => {
  const [ref, setRef] = useState(null)
  const [isClient, setIsClient] = useState(false)

  useEffect(() => setIsClient(true), [])

  if (!isClient) {
    return null
  }

  return (
    <Suspense fallback={<Loading />}>
      <ModelProvider modelid={modelid}>
        <BandDataProvider>
          {/* MAP OBJECT */}
          <Map container={ref} />

          {/* MAP UI */}
          <Div sx={{ display: 'flex', flex: 1, flexDirection: 'column' }}>
            <Div sx={{ display: 'flex', flex: 1, flexDirection: 'row' }}>
              <Div sx={{ flex: 1 }} ref={el => setRef(el)} />
              <Paper
                variant="outlined"
                sx={{
                  borderRadius: 0,
                  borderBottom: 'none',
                  py: theme => theme.spacing(3),
                }}
              >
                <DepthControl />
              </Paper>
            </Div>

            <Paper
              sx={{
                borderRadius: 0,
                px: theme => theme.spacing(1),
              }}
              variant="outlined"
            >
              <TimeControl />
            </Paper>
          </Div>
        </BandDataProvider>
      </ModelProvider>
    </Suspense>
  )
}
