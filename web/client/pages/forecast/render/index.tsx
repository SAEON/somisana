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
import { DragHorizontal } from '../../../components/icons'
import ColorBar from './controls/color-bar'
import Map from './map'
import Stack from '@mui/material/Stack'
import Timestamp from './controls/timestamp'
import { ToggleData } from './controls/data'
import LayerControl from './controls/layers'
import Draggable from 'react-draggable'

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
                <Draggable
                  onStop={e => {
                    globalThis.dispatchEvent(
                      new CustomEvent('interaction', {
                        detail: { type: 'drag-right-menu' },
                      })
                    )
                  }}
                  handle="#draggable-right-menu"
                >
                  <Stack
                    sx={{
                      opacity: 0.8,
                      position: 'absolute',
                      alignItems: 'center',
                      zIndex: 1,
                      right: 0,
                      boxShadow: theme => theme.shadows[3],
                      padding: theme => theme.spacing(1),
                      borderRadius: theme => `${theme.shape.borderRadius}px`,
                      backgroundColor: theme => theme.palette.background.paper,
                      marginTop: theme => theme.spacing(2),
                      marginRight: theme => theme.spacing(2),
                    }}
                    direction="column"
                    spacing={1}
                  >
                    <DragHorizontal
                      id="draggable-right-menu"
                      sx={{
                        cursor: 'move',
                      }}
                    />
                    <ToggleConfig />
                    <InfoControl />
                    <LayerControl />
                    <ToggleData />
                    <ToggleTemperature />
                    <ToggleSalinity />
                    <ToggleCurrents />
                  </Stack>
                </Draggable>
              </Div>

              {/* RIGHT MENU */}
              <Paper
                variant="outlined"
                sx={{
                  padding: theme => `${theme.spacing(3)} 0`,
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
