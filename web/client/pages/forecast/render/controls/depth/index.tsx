import { useContext } from 'react'
import { context as modelContext } from '../../_context'
import Slider from '@mui/material/Slider'
import Typography from '@mui/material/Typography'
import Div from '../../../../../components/div'

const marks = [
  { depth: -99999, value: -30, label: 'Btm' },
  { depth: -2000, value: -26, label: '2000' },
  { depth: -1000, value: -22.5, label: '1000' },
  { depth: -500, value: -19, label: '500' },
  { depth: -200, value: -16, label: '200' },
  { depth: -100, value: -13.5, label: '100' },
  { depth: -70, value: -11.5, label: '70' },
  { depth: -60, value: -10, label: '60' },
  { depth: -50, value: -8.5, label: '50' },
  { depth: -40, value: -7, label: '40' },
  { depth: -30, value: -5.5, label: '30' },
  { depth: -20, value: -4, label: '20' },
  { depth: -15, value: -3, label: '15' },
  { depth: -10, value: -2, label: '10' },
  { depth: -5, value: -1, label: '5' },
  { depth: 0, value: 0, label: '0' },
]

export default () => {
  const { depth, setDepth } = useContext(modelContext)

  return (
    <Div sx={{ display: 'flex', flexDirection: 'column', flex: 1, alignItems: 'center' }}>
      <Typography variant="overline" sx={{ marginBottom: theme => theme.spacing(1) }}>
        Depth
      </Typography>
      <Slider
        sx={{
          marginTop: theme => theme.spacing(1),
          marginLeft: theme => `${theme.spacing(1)}`,
          borderRadius: 0,
          width: '8px',
          '& .MuiSlider-track': {
            height: '13.3% !important',
            width: '4px',
            color: 'transparent',
          },
          '& .MuiSlider-mark': {
            height: '1px',
            width: '8px',
            backgroundColor: theme => theme.palette.primary.main,
          },
          '& .MuiSlider-markLabel': {
            fontSize: '0.6rem',
          },
        }}
        aria-label="Depth level"
        value={marks.find(({ depth: d }) => depth === d).value}
        size="small"
        scale={x => x}
        min={marks[0].value}
        max={marks[marks.length - 1].value}
        orientation="vertical"
        step={null}
        onChangeCommitted={(_, val) => {
          const depth = marks.find(({ value }) => value == val).depth
          setDepth(depth)
        }}
        valueLabelDisplay="off"
        marks={marks}
        track="normal"
      />
    </Div>
  )
}
