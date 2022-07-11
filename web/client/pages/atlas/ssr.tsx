import Box from '@mui/material/Box'
import Map from './map'

export default () => {
  return (
    <Box
      sx={{
        flexGrow: 1,
        background: theme =>
          `linear-gradient(to top, ${theme.palette.primary.light}, ${theme.palette.grey[100]}, ${theme.palette.common.white})`,
      }}
    >
      <Map />
    </Box>
  )
}
