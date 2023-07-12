import LinearProgress from '@mui/material/LinearProgress'
import CircularProgress from '@mui/material/CircularProgress'
import { styled } from '@mui/material/styles'

export const Linear = styled(props => (
  <LinearProgress style={{ zIndex: 1099, position: 'absolute', width: '100%' }} {...props} />
))({})

export const Circular = styled(props => <CircularProgress style={{ zIndex: 1099 }} {...props} />)(
  {}
)
