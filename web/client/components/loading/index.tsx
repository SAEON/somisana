import LinearProgress from '@mui/material/LinearProgress'
import CircularProgress from '@mui/material/CircularProgress'
import styled from '@mui/material/styles/styled'

const LoadingLinear = props => (
  <LinearProgress style={{ zIndex: 1099, position: 'absolute', width: '100%' }} {...props} />
)

const LoadingCircular = props => <CircularProgress style={{ zIndex: 1099 }} {...props} />

export const Linear = styled(LoadingLinear)({})
export const Circular = styled(LoadingCircular)({})
