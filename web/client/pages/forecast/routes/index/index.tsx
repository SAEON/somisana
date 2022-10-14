import { Suspense, useState, useEffect } from 'react'
import { Linear as Loading } from '../../../../components/loading'
import Div from '../../../../components/div'
import Paper from '@mui/material/Paper'
import ModelProvider from './_context'
import BandDataProvider from './band-data'
import { ToggleDepth } from './controls/depth'
import ToggleTemperature from './controls/toggle-temperature'
import ToggleSalinity from './controls/toggle-salinity'
import TimeControl from './controls/time'
import InfoControl from './controls/info'
import ColorBar from './controls/color-bar'
import Map from './map'
import Stack from '@mui/material/Stack'
import RightMenu from './right-menu'

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
                {/* COLOR BAR */}
                <ColorBar />

                {/* FLOATING MENU */}

                <Stack
                  sx={{
                    position: 'absolute',
                    zIndex: 1,
                    right: 0,
                    mt: theme => theme.spacing(1),
                    mr: theme => theme.spacing(1),
                  }}
                  direction="column"
                  spacing={1}
                >
                  <InfoControl />
                  <ToggleDepth />
                  <ToggleTemperature />
                  <ToggleSalinity />
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
