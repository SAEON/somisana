import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Paper from '@mui/material/Paper'
import format from 'date-fns/format'
import add from 'date-fns/add'
import Draggable from 'react-draggable'
import Typography from '@mui/material/Typography'
import Span from '../../../../../components/span'
import { DragVertical as DragHandle } from '../../../../../components/icons'
import Divider from '@mui/material/Divider'
import B from '../../../../../components/b'
import I from '../../../../../components/i'

export default () => {
  const { runs, timeStep, activeRun } = useContext(modelContext)
  const run = runs[activeRun]
  const stepDifference = timeStep - 1
  const startTime = new Date(run?.step1_timestamp)
  const ts = add(startTime, {
    hours: stepDifference,
  })
  const runDate = new Date(run?.run_date)

  return (
    <Span
      sx={{
        zIndex: 10,
        position: 'absolute',
        display: 'flex',
        justifyContent: 'center',
        width: '100%',
        top: theme => theme.spacing(-8),
      }}
    >
      <Draggable
        onStop={e => {
          globalThis.dispatchEvent(
            new CustomEvent('interaction', {
              detail: { type: 'drag-timestamp' },
            })
          )
        }}
        handle="#draggable-time-info"
      >
        <Paper
          sx={{
            opacity: 0.8,
            position: 'relative',
            top: theme => theme.spacing(11),
            cursor: 'move',
            boxShadow: theme => theme.shadows[3],
            padding: theme => `${theme.spacing(1)} ${theme.spacing(2)}`,
            textAlign: 'center',
            display: 'flex',
            alignItems: 'center',
          }}
          id="draggable-time-info"
        >
          <DragHandle
            fontSize="small"
            sx={{ position: 'relative', left: theme => `-${theme.spacing(1)}` }}
          />
          <Typography variant="overline">
            <B>Run: {format(runDate, 'dd MMM yyyy')}</B>
          </Typography>
          <Divider
            sx={{ margin: theme => `0 ${theme.spacing(1)}` }}
            flexItem
            orientation="vertical"
          />
          <Typography variant="overline">
            <I>
              Forecast: {run?.step1_timestamp ? format(ts, 'MMM dd HH:mm') : 'Missing timestamp'}
            </I>
          </Typography>
        </Paper>
      </Draggable>
    </Span>
  )
}
