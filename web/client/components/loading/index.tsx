import LinearProgress from '@mui/material/LinearProgress'
import { styled } from '@mui/material/styles'

const Loading = props => <LinearProgress style={{ zIndex: 1099 }} {...props} />

export default styled(Loading)({})
