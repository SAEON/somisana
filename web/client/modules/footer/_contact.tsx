import { useContext } from 'react'
import { context as configContext } from '../../modules/config'
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'

export default () => {
  const { TECHNICAL_CONTACT } = useContext(configContext)

  return (
    <Grid container spacing={2}>
      <Grid item xs={12}>
        <Typography variant="h5">Contact us</Typography>
      </Grid>
      <Grid item xs={12}>
        <Typography variant="body1">Model enquiries</Typography>
        <Typography variant="body2">{TECHNICAL_CONTACT.replace('@', ' [ at ] ')}</Typography>
      </Grid>
      <Grid item xs={12}>
        <Typography variant="body1">Bugs / technical support</Typography>
        <Typography variant="body2">https://github.com/SAEON/somisana/issues</Typography>
      </Grid>
    </Grid>
  )
}
