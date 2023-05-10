import { Suspense, useState, useEffect, lazy } from 'react'
import { Linear as Loading } from '../../../components/loading'
import Div from '../../../components/div'
import Paper from '@mui/material/Paper'
import BandDataProvider from './band-data'
import DepthControl from './controls/depth'
import ToggleTemperature from './controls/toggle-temperature'
import ToggleSalinity from './controls/toggle-salinity'
import ToggleCurrents from './controls/toggle-currents'
import TimeControl from './controls/time'
import DataExplorer from './controls/data-explorer'
import InfoControl from './controls/info'
import { ToggleConfig } from './controls/color-bar'
import ColorBar from './controls/color-bar'
import Map from './map'
import Stack from '@mui/material/Stack'
import Timestamp from './controls/timestamp'
import { ToggleData } from './controls/data'
import LayerControl from './controls/layers'

const ModelProvider = lazy(() => import('./_context'))

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
              <Div sx={{ flex: 1 }} ref={el => setRef(el)}>
                {/* FLOATING TIMESTAMP */}
                <Timestamp />

                {/* COLOR BAR */}
                <ColorBar />

                {/* FLOATING RIGHT MENU */}
                <Stack
                  sx={{
                    position: 'absolute',
                    zIndex: 1,
                    right: 0,
                    mt: theme => theme.spacing(2),
                    mr: theme => theme.spacing(2),
                  }}
                  direction="column"
                  spacing={1}
                >
                  <ToggleConfig />
                  <InfoControl />
                  <LayerControl />
                  <ToggleData />
                  <ToggleTemperature />
                  <ToggleSalinity />
                  <ToggleCurrents />
                </Stack>
              </Div>

              {/* RIGHT MENU */}
              <Paper
                variant="outlined"
                sx={{
                  py: 3,
                  borderRadius: 0,
                  borderBottom: 'none',
                }}
              >
                <DepthControl />
              </Paper>
            </Div>

            {/* BOTTOM MENU */}
            <Paper
              sx={{
                borderRadius: 0,
                px: theme => theme.spacing(1),
              }}
              variant="outlined"
            >
              <TimeControl />
              <DataExplorer />
            </Paper>
          </Div>
        </BandDataProvider>
      </ModelProvider>
    </Suspense>
  )
}
