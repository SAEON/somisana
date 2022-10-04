import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Slider from '@mui/material/Slider'

const marks = [
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
  const { setDepth } = useContext(modelContext)

  return (
    <Slider
      sx={{
        '& .MuiSlider-mark': {
          height: '1px',
          width: '12px',
        },
      }}
      aria-label="Depth level"
      defaultValue={0}
      size="small"
      scale={x => x}
      min={marks[0].value}
      max={marks[marks.length - 1].value}
      orientation="vertical"
      step={null}
      onChangeCommitted={(_, val) => setDepth(val)}
      valueLabelDisplay="off"
      marks={marks}
      track={false}
    />
  )
}