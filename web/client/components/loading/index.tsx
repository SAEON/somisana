import LinearProgress from '@mui/material/LinearProgress'

const Loading = ({ msg = undefined }) => (
  <>
    <LinearProgress style={{ zIndex: 1099 }} />
    {msg && msg}
  </>
)

export default Loading
