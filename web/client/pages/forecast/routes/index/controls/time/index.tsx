import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Div from '../../../../../../components/div'
import Span from '../../../../../../components/span'
import Slider from './_slider'
import { styled } from '@mui/material/styles'
import IconButton_ from '@mui/material/IconButton'
import { useSnackbar } from 'notistack'
import {
  Play,
  SkipNext,
  SkipBack,
  Pause,
  SkipBackward,
  SkipForward,
} from '../../../../../../components/icons'
import Tooltip from '@mui/material/Tooltip'
import format from 'date-fns/format'
import add from 'date-fns/add'

const IconButton = styled(IconButton_)({ padding: '2px' })

const TIMESTEP_OFFSET = 24

export default () => {
  const {
    timeStep,
    setTimeStep,
    activeRun,
    setActiveRun,
    animateTimeStep,
    setAnimateTimeStep,
    run,
    runs,
  } = useContext(modelContext)
  const t0 = run?.step1_timestamp ? new Date(run.step1_timestamp) : 'Missing timestep'
  const mostRecentRun = Boolean(activeRun <= 0)
  const { enqueueSnackbar } = useSnackbar()

  const label =
    t0.constructor === Date
      ? format(
          add(t0, {
            hours: timeStep - 1,
          }),
          'MMM dd HH:mm'
        )
      : timeStep

  return (
    <Div sx={{ alignItems: 'center', position: 'relative', display: 'flex', flexDirection: 'row' }}>
      {/* PREV RUN */}
      <Tooltip title="Go to previous run" placement="top-start">
        <Span>
          <IconButton
            onClick={() => {
              const nextTimeStep = timeStep + TIMESTEP_OFFSET
              if (nextTimeStep > 240) {
                enqueueSnackbar(
                  `The previous model run does not forecast ${label}. Please adjust the time step manually so that there is overlapping forecast data between this and the previous model run`,
                  {
                    variant: 'default',
                  }
                )
              } else {
                setActiveRun(i => i + 1)
                setTimeStep(nextTimeStep)
              }
            }}
            size="small"
          >
            <SkipBackward />
          </IconButton>
        </Span>
      </Tooltip>

      {/* PREV TIMESTEP */}
      <Tooltip title="Go to previous time frame" placement="top-start">
        <Span>
          <IconButton onClick={() => setTimeStep(t => t - 1)} disabled={timeStep <= 1} size="small">
            <SkipBack />
          </IconButton>
        </Span>
      </Tooltip>

      {/* PLAY */}
      <Tooltip title="Auto-increment time frames" placement="top-start">
        <Span>
          <IconButton onClick={() => setAnimateTimeStep(v => !v)} size="small">
            {animateTimeStep && <Pause />}
            {!animateTimeStep && <Play />}
          </IconButton>
        </Span>
      </Tooltip>

      {/* NEXT TIMESTEP */}
      <Tooltip title="Go to next time frame" placement="top-start">
        <Span>
          <IconButton
            onClick={() => setTimeStep(t => t + 1)}
            disabled={timeStep >= 240}
            size="small"
          >
            <SkipNext />
          </IconButton>
        </Span>
      </Tooltip>

      {/* NEXT RUN */}
      <Tooltip title={mostRecentRun ? 'Most recent run' : 'Go to next run'} placement="top-start">
        <Span>
          <IconButton
            disabled={mostRecentRun}
            onClick={() => {
              const nextTimeStep = timeStep - TIMESTEP_OFFSET
              if (nextTimeStep <= 0) {
                enqueueSnackbar(
                  `The next model run does not forecast ${label}. Please adjust the time step manually so that there is overlapping forecast data between this and the next model run`,
                  {
                    variant: 'default',
                  }
                )
              } else {
                setActiveRun(i => i - 1)
                setTimeStep(nextTimeStep)
              }
            }}
            sx={{ mr: theme => theme.spacing(2) }}
            size="small"
          >
            <SkipForward />
          </IconButton>
        </Span>
      </Tooltip>

      {/* TIME SLIDER */}
      <Slider t0={t0} timeStep={timeStep} setTimeStep={setTimeStep} />
    </Div>
  )
}
