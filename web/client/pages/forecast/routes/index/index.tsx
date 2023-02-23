import { Suspense, useState, useEffect, lazy } from 'react'
import { Linear as Loading } from '../../../../components/loading'
import Div from '../../../../components/div'
import Paper from '@mui/material/Paper'
import BandDataProvider from './band-data'
import { ToggleDepth } from './controls/depth'
import ToggleTemperature from './controls/toggle-temperature'
import ToggleSalinity from './controls/toggle-salinity'
import ToggleCurrents from './controls/toggle-currents'
import TimeControl from './controls/time'
import InfoControl from './controls/info'
import { ToggleConfig } from './controls/color-bar'
import ColorBar from './controls/color-bar'
import Map from './map'
import Stack from '@mui/material/Stack'
import RightMenu from './right-menu'
import Timestamp from './controls/timestamp'

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

                {/* FLOATING MENU */}
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
                  <ToggleDepth />
                  <ToggleTemperature />
                  <ToggleSalinity />
                  <ToggleCurrents />
                </Stack>
              </Div>

              {/* RIGHT MENU */}
              <RightMenu />
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
            </Paper>
          </Div>
        </BandDataProvider>
      </ModelProvider>
    </Suspense>
  )
}
