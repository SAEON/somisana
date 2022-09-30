import Div from '../../../../components/div'
import Paper from '@mui/material/Paper'
import ModelProvider from './_context'
import BandDataProvider from './band-data'
import DepthControl from './controls/depth'
import TimeControl from './controls/time'
import Map from './map'

export default ({ container }) => {
  return (
    <ModelProvider>
      <BandDataProvider>
        <Map container={container} />

        <Paper>
          <DepthControl />
        </Paper>

        <Div
          sx={{
            zIndex: 1,
            width: '100%',
            p: theme => theme.spacing(2),
            position: 'fixed',
            bottom: 0,
          }}
        >
          <Paper
            sx={{
              px: theme => theme.spacing(2),
              backgroundColor: `rgba(255,255,255,0.8)`,
              width: '100%',
            }}
          >
            <TimeControl />
          </Paper>
        </Div>
      </BandDataProvider>
    </ModelProvider>
  )
}
