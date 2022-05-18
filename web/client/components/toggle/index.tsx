import { forwardRef } from 'react'
import FormControl from '@mui/material/FormControl'
import FormControlLabel from '@mui/material/FormControlLabel'
import Switch from '@mui/material/Switch'
import { styled } from '@mui/material/styles'

const Toggle = forwardRef(({ labelProps, switchProps, ...props }, ref) => (
  <FormControl fullWidth margin="dense" ref={ref} {...props}>
    <FormControlLabel sx={{
      mr: 0,
      justifyContent: 'space-between'
    }} control={<Switch {...switchProps} />} {...labelProps}  />
  </FormControl>
))

export default styled(Toggle)({})
