import { useContext } from 'react'
import { context as modelContext } from '../../../_context'
import Div from '../../../../../../../components/div'
import Slider from '@mui/material/Slider'
import Typography from '@mui/material/Typography'

const marks = [
  {
    value: -120,
    label: '120 M',
  },

  {
    value: -80,
    label: '80 M',
  },

  {
    value: -40,
    label: '40 M',
  },

  {
    value: -20,
    label: '20 M',
  },

  {
    value: -15,
    label: '15 M',
  },
  {
    value: -10,
    label: '10 M',
  },
  {
    value: -5,
    label: '05 M',
  },

  {
    value: 0,
    label: 'Surface',
  },
]

export default () => {
  const { setDepth } = useContext(modelContext)

  return (
    <Div sx={{ maxHeight: 500, position: 'relative', display: 'flex', flexDirection: 'column' }}>
      <Typography
        variant="overline"
        sx={{ textAlign: 'center', display: 'block', mb: theme => theme.spacing(2) }}
      >
        Depth
      </Typography>
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
    </Div>
  )
}
