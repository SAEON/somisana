import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Div from '../../../../../../components/div'
import Slider from '@mui/material/Slider'
import Typography from '@mui/material/Typography'

const marks = [
  {
    value: -500,
    label: '500 M',
  },
  {
    value: -200,
    label: '200 M',
  },

  {
    value: -100,
    label: '100 M',
  },

  {
    value: -50,
    label: '50 M',
  },

  {
    value: -25,
    label: '25 M',
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
