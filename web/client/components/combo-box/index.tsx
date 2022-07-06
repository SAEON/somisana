import { forwardRef } from 'react'
import Autocomplete from '@mui/material/Autocomplete'
import TextField from '@mui/material/TextField'
import styled from '@mui/material/styles/styled'

const ComboBox = forwardRef((props, ref) => {
  const { label, options, ...otherProps } = props

  return (
    <Autocomplete
      ref={ref}
      disablePortal
      id={`combo-box-${label}`}
      options={options}
      fullWidth
      size="small"
      renderInput={params => <TextField size="small" margin="normal" {...params} label={label} />}
      {...otherProps}
    />
  )
})

export default styled(ComboBox)({})
