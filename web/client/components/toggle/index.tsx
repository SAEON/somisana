import FormControlLabel from '@mui/material/FormControlLabel'
import Switch from '@mui/material/Switch'
import { styled } from '@mui/material/styles'

const StyledLabel = styled(FormControlLabel)({
  width: '100%',
  justifyContent: 'space-between',
  marginRight: 0,
})

const Toggle = ({ labelProps, switchProps }) => (
  <StyledLabel control={<Switch {...switchProps} />} {...labelProps} />
)

export default Toggle
