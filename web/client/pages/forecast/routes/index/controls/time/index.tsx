import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Div from '../../../../../../components/div'
import Slider from './_slider'
import { styled } from '@mui/material/styles'
import IconButton_ from '@mui/material/IconButton'
import { Play, SkipNext, SkipBack, Pause } from '../../../../../../components/icons'
import Tooltip from '@mui/material/Tooltip'

const IconButton = styled(IconButton_)({ padding: '2px' })

export default () => {
  const { timeStep, setTimeStep, animateTimeStep, setAnimateTimeStep } = useContext(modelContext)

  return (
    <Div sx={{ alignItems: 'center', position: 'relative', display: 'flex', flexDirection: 'row' }}>
      <Tooltip title="Go to previous time frame" placement="top-start">
        <span>
          <IconButton onClick={() => setTimeStep(t => t - 1)} disabled={timeStep <= 1} size="small">
            <SkipBack />
          </IconButton>
        </span>
      </Tooltip>
      <Tooltip title="Auto-increment time frames" placement="top-start">
        <span>
          <IconButton onClick={() => setAnimateTimeStep(v => !v)} size="small">
            {animateTimeStep && <Pause />}
            {!animateTimeStep && <Play />}
          </IconButton>
        </span>
      </Tooltip>
      <Tooltip title="Go to next time frame" placement="top-start">
        <span>
          <IconButton
            onClick={() => setTimeStep(t => t + 1)}
            disabled={timeStep >= 240}
            sx={{ mr: theme => theme.spacing(2) }}
            size="small"
          >
            <SkipNext />
          </IconButton>
        </span>
      </Tooltip>
      <Slider timeStep={timeStep} setTimeStep={setTimeStep} />
    </Div>
  )
}
