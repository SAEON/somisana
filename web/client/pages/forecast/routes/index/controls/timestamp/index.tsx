import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Paper from '@mui/material/Paper'
import format from 'date-fns/format'
import add from 'date-fns/add'
import Draggable from 'react-draggable'
import Typography from '@mui/material/Typography'
import Span from '../../../../../../components/span'
import { DragVertical as DragHandle } from '../../../../../../components/icons'
import Divider from '@mui/material/Divider'

export default () => {
  const { run, timeStep } = useContext(modelContext)

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
        mt: 3,
      }}
    >
      <Draggable handle="#draggable-time-info">
        <Paper
          sx={{
            cursor: 'move',
            boxShadow: theme => theme.shadows[3],
            px: 2,
            py: 1.5,
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
          <Typography variant="body1">{format(runDate, 'do MMM')}</Typography>
          <Divider sx={{ mx: 1 }} flexItem orientation="vertical" />
          <Typography variant="body1">
            {run?.step1_timestamp ? format(ts, 'HH:mm dd MMM yyyy') : 'Missing timestamp'}
          </Typography>
        </Paper>
      </Draggable>
    </Span>
  )
}
