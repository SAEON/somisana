import Typography from '@mui/material/Typography'
import { alpha } from '@mui/system/colorManipulator'

export default ({ children }) => {
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
      {children}
    </Typography>
  )
}
