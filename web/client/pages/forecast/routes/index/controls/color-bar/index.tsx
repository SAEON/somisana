import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Config from './config'
import invertColor, { padZero } from './_invert-color'
import Paper from '@mui/material/Paper'
import Tooltip from '@mui/material/Tooltip'
import Typography from '@mui/material/Typography'
import Div from '../../../../../../components/div'

export default () => {
  const { scaleMin, scaleMax, setScaleMin, setScaleMax, color } = useContext(modelContext)
  return (
    <Paper
      sx={{
        my: theme => theme.spacing(8),
        mx: theme => theme.spacing(2),
        height: '100%',
        maxHeight: 'fill-available',
        position: 'absolute',
        left: 0,
        zIndex: 1,
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        overflow: 'auto',
      }}
    >
      <Config
        scaleMin={scaleMin}
        scaleMax={scaleMax}
        setScaleMin={setScaleMin}
        setScaleMax={setScaleMax}
      />
      {new Array((scaleMax - scaleMin) / 0.1)
        .fill(null)
        .map((_, i) => i / 10 + scaleMin)
        .reverse()
        .map((value, i) => {
          return (
            <Tooltip key={i} placement="right-start" title={`${value} °C`}>
              <Div
                sx={{
                  backgroundColor: color(value),
                  flex: 1,
                  display: 'flex',
                  px: theme => theme.spacing(1),
                }}
              >
                {value.toFixed(0) == value && (
                  <Typography
                    sx={{
                      fontSize: '0.7rem',
                      fontWeight: 'bold',
                      color: invertColor(color(value), true),
                    }}
                    variant="overline"
                  >
                    {padZero(value)} °C
                  </Typography>
                )}
              </Div>
            </Tooltip>
          )
        })}
    </Paper>
  )
}
