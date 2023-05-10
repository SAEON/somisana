import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Slider from '@mui/material/Slider'

const marks = [
  {
    value: -550, // This value should actually be -9999, but using -550 looks better on the slider
    label: 'B',
  },
  {
    value: -500,
    label: '500',
  },
  {
    value: -250,
    label: '250',
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
        ml: 0.5,
        mr: 4,
        '& .MuiSlider-track': {
          height: '9% !important',
          color: theme => theme.palette.common.black,
        },
        '& .MuiSlider-mark': {
          height: '1px',
          width: '12px',
          backgroundColor: theme => theme.palette.primary.main,
        },
        '& .MuiSlider-markLabel': {
          fontSize: '0.6rem',
        },
      }}
      aria-label="Depth level"
      value={depth}
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
