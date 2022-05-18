import { forwardRef } from 'react'
import FormControlLabel from '@mui/material/FormControlLabel'
import Switch from '@mui/material/Switch'
import { styled } from '@mui/material/styles'

const StyledLabel = styled(FormControlLabel)({
  width: '100%',
  justifyContent: 'space-between',
  marginRight: 0,
})

const Toggle = forwardRef(({ labelProps, switchProps, ...props }, ref) => (
  <StyledLabel ref={ref} control={<Switch {...switchProps} />} {...labelProps} {...props} />
))

export default Toggle
