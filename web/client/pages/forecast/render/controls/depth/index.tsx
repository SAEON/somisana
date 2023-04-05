import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Slider from '@mui/material/Slider'
import IconButton from '@mui/material/IconButton'
import { SigmaLower } from '../../../../../components/icons'
import Tooltip from '@mui/material/Tooltip'

export const ToggleDepth = () => {
  const { activeRightPane, setActiveRightPane } = useContext(modelContext)
  return (
    <Tooltip placement="left-start" title="Toggle depth control pane">
      <IconButton
        size="small"
        color="primary"
        sx={{ zIndex: 11 }}
        onClick={() => setActiveRightPane(a => (a === 'depth' ? false : 'depth'))}
      >
        <SigmaLower
          sx={{
            color: theme => (activeRightPane === 'depth' ? theme.palette.success.dark : 'primary'),
          }}
          fontSize="small"
        />
      </IconButton>
    </Tooltip>
  )
}

const marks = [
  {
    value: -550,
    label: 'B',
  },
  {
    value: -500,
    label: '500',
  },
  {
    value: -200,
    label: '200',
  },

  {
    value: -100,
    label: '100',
  },

  {
    value: -50,
    label: '50',
  },

  {
    value: -25,
    label: '25',
  },

  {
    value: 0,
    label: 'S',
  },
]

export default () => {
  const { depth, setDepth } = useContext(modelContext)

  return (
    <Slider
      sx={{
        ml: 3,
        '& .MuiSlider-track': {
          height: '9% !important',
          color: theme => theme.palette.common.black,
        },
        '& .MuiSlider-mark': {
          height: '1px',
          width: '12px',
          backgroundColor: theme => theme.palette.primary.main,
        },
      }}
      aria-label="Depth level"
      defaultValue={depth}
      size="small"
      scale={x => x}
      min={marks[0].value}
      max={marks[marks.length - 1].value}
      orientation="vertical"
      step={null}
      onChangeCommitted={(_, val) => setDepth(val)}
      valueLabelDisplay="off"
      marks={marks}
      track="normal"
    />
  )
}
