import { useState, useEffect } from 'react'

import Slider from '@mui/material/Slider'

export default ({ timeStep, setTimeStep }) => {
  const [step, setStep] = useState(timeStep)

  useEffect(() => {
    setStep(timeStep)
  }, [timeStep])

  return (
    <Slider
      sx={{
        zIndex: 20,
        '& .MuiSlider-mark': {
          height: '12px',
          width: '1px',
        },
      }}
      aria-label="Depth level"
      defaultValue={timeStep}
      size="small"
      scale={x => x}
      min={1}
      max={240}
      orientation="horizontal"
      step={1}
      valueLabelDisplay="auto"
      track={false}
      value={step}
      onChange={(_, val) => setStep(val)}
      onChangeCommitted={(_, val) => setTimeStep(val)}
      valueLabelFormat={val => `TIMESTAMP ${val}`}
    />
  )
}
