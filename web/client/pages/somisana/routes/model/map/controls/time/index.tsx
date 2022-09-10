import { useContext } from 'react'
import { context as modelContext } from '../../../_context'
import Div from '../../../../../../../components/div'
import Slider from '@mui/material/Slider'
import Typography from '@mui/material/Typography'

export default () => {
  const { setTimeStep } = useContext(modelContext)

  return (
    <Div sx={{ alignItems: 'center', position: 'relative', display: 'flex', flexDirection: 'row' }}>
      <Typography
        variant="overline"
        sx={{ textAlign: 'center', display: 'block', mr: theme => theme.spacing(2) }}
      >
        Time
      </Typography>
      <Slider
        sx={{
          zIndex: 20,
          '& .MuiSlider-mark': {
            height: '12px',
            width: '1px',
          },
        }}
        aria-label="Depth level"
        defaultValue={1}
        size="small"
        scale={x => x}
        min={1}
        max={240}
        orientation="horizontal"
        step={1}
        valueLabelDisplay="auto"
        track={false}
        onChangeCommitted={(_, val) => setTimeStep(val)}
        valueLabelFormat={val => `TIMESTAMP ${val}`}
      />
    </Div>
  )
}
