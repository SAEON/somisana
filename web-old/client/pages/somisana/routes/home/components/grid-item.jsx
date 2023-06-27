import Grid from '@mui/material/Grid'

export default ({ sx = {}, xs = 12, sm = 6, md = 4, ...props }) => (
  <Grid
    sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', ...sx }}
    item
    xs={xs}
    sm={sm}
    md={md}
    {...props}
  />
)
