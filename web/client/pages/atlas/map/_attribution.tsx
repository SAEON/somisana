import Typography from '@mui/material/Typography'
import Link from '@mui/material/Link'
import { alpha } from '@mui/material/styles'

export default () => {
  return (
    <Typography
      variant="caption"
      sx={{
        position: 'absolute',
        bottom: 0,
        right: 0,
        backgroundColor: theme => alpha(theme.palette.common.white, 0.8),
        m: theme => theme.spacing(0),
        p: theme => theme.spacing(0.5),
        zIndex: 1,
      }}
    >
      ©{' '}
      <Link
        target="_blank"
        rel="noopener noreferrer"
        href="https://www.openstreetmap.org/copyright"
      >
        OpenStreetMap
      </Link>{' '}
      contributors
    </Typography>
  )
}
