import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Div from '../../../../../../components/div'
import Span from '../../../../../../components/span'
import Slider from './_slider'
import { styled } from '@mui/material/styles'
import IconButton_ from '@mui/material/IconButton'
import {
  Play,
  SkipNext,
  SkipBack,
  Pause,
  SkipBackward,
  SkipForward,
} from '../../../../../../components/icons'
import Tooltip from '@mui/material/Tooltip'

const IconButton = styled(IconButton_)({ padding: '2px' })

export default () => {
  const { timeStep, setTimeStep, animateTimeStep, setAnimateTimeStep } = useContext(modelContext)

  return (
    <Div sx={{ alignItems: 'center', position: 'relative', display: 'flex', flexDirection: 'row' }}>
      {/* PREV RUN */}
      <Tooltip title="Go to previous run" placement="top-start">
        <Span>
          <IconButton disabled size="small">
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
      <Tooltip title="Go to next run" placement="top-start">
        <Span>
          <IconButton disabled sx={{ mr: theme => theme.spacing(2) }} size="small">
            <SkipForward />
          </IconButton>
        </Span>
      </Tooltip>

      {/* TIME SLIDER */}
      <Slider timeStep={timeStep} setTimeStep={setTimeStep} />
    </Div>
  )
}
