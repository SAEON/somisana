import Box from '@mui/material/Box'
import Map from './map'

export default () => {
  return (
    <Box
      sx={{
        flexGrow: 1,
        background: theme => theme.palette.grey[100],
        transition: theme => theme.transitions.create(['background-color']),
      }}
    >
      <Map />
    </Box>
  )
}
