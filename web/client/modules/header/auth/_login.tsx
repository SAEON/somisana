import Typography from '@mui/material/Typography'
import Link from '@mui/material/Link'

export default () => {
  return (
    <Typography href="https://google.com" component={Link}>
      Log in
    </Typography>
  )
}
