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
import Timestamp from './controls/timestamp'
import { ToggleData } from './controls/data'
import LayerControl from './controls/layers'
import LockColorBar from './controls/lock-color-bar'
import RefreshColorRange from './controls/refresh-color-range'
import BandDataTable from './controls/band-data'

const ModelProvider = lazy(() => import('./_context'))
const FloatingMenu = lazy(() => import('./floating-menu'))

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
          <Div
            sx={{
              display: 'flex',
              flex: 1,
              flexDirection: 'column',
              backgroundColor: theme => theme.palette.background.paper,
            }}
          >
            <Div sx={{ display: 'flex', flex: 1, flexDirection: 'row' }}>
              <Div sx={{ flex: 1 }} ref={el => setRef(el)}>
                {/* FLOATING TIMESTAMP */}
                <Timestamp />

                {/* COLOR BAR */}
                <ColorBar />

                {/* FLOATING RIGHT MENUS */}
                <Div
                  sx={{
                    position: 'absolute',
                    display: 'flex',
                    alignItems: 'flex-start',
                    flexDirection: 'column',
                    right: 0,
                    marginTop: theme => theme.spacing(2),
                    marginRight: theme => theme.spacing(2),
                  }}
                >
                  <Suspense fallback={null}>
                    <FloatingMenu
                      id="fm2"
                      sx={{
                        marginBottom: theme => theme.spacing(2),
                      }}
                    >
                      <InfoControl />
                      <ToggleData />
                      <BandDataTable />
                    </FloatingMenu>
                  </Suspense>
                  <Suspense fallback={null}>
                    <FloatingMenu
                      id="fm1"
                      sx={{
                        marginBottom: theme => theme.spacing(2),
                      }}
                    >
                      <ToggleConfig />
                      <LockColorBar />
                      <RefreshColorRange />
                    </FloatingMenu>
                  </Suspense>
                  <Suspense fallback={null}>
                    <FloatingMenu id="fm3">
                      <LayerControl />
                      <ToggleTemperature />
                      <ToggleSalinity />
                      <ToggleCurrents />
                    </FloatingMenu>
                  </Suspense>
                </Div>
              </Div>

              {/* RIGHT MENU */}
              <Paper
                variant="outlined"
                sx={{
                  padding: theme => `${theme.spacing(1)} 0`,
                  alignItems: 'center',
                  display: 'flex',
                  borderRadius: 0,
                  flexDirection: 'column',
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
                padding: theme => `0 ${theme.spacing(1)}`,
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
