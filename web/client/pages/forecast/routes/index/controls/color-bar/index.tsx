import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Config from './config'
import invertColor, { padZero } from './_invert-color'
import Tooltip from '@mui/material/Tooltip'
import Typography from '@mui/material/Typography'
import Div from '../../../../../../components/div'
import Stack from '@mui/material/Stack'

export default () => {
  const { scaleMin, scaleMax, setScaleMin, setScaleMax, color } = useContext(modelContext)
  return (
    <Stack
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
      {new Array((Math.ceil(scaleMax) - Math.floor(scaleMin)) / 0.2)
        .fill(null)
        .map((_, i) => parseFloat((i / 5 + scaleMin).toFixed(1)))
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
                {value % 2 == 0 && (
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
    </Stack>
  )
}
