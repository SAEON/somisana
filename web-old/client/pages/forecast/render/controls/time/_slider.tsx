import { useState, useEffect } from 'react'
import format from 'date-fns/format'
import add from 'date-fns/add'
import Slider from '@mui/material/Slider'

export default ({ timeStep, setTimeStep, t0 }) => {
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
      onChangeCommitted={(_, val) => {
        globalThis.dispatchEvent(
          new CustomEvent('interaction', {
            detail: { timeStep: val, type: 'change-timestep' },
          })
        )
        setTimeStep(val)
      }}
      valueLabelFormat={val =>
        t0.constructor === Date
          ? format(
              add(t0, {
                hours: val - 1,
              }),
              'MMM dd HH:mm'
            )
          : val
      }
    />
  )
}
