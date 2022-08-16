import Grid from '@mui/material/Grid'

export default ({ sx = {}, ...props }) => (
  <Grid
    sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', ...sx }}
    item
    xs={12}
    sm={6}
    md={4}
    {...props}
  />
)
