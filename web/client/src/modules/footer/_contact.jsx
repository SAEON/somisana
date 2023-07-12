import { useContext } from 'react'
import { context as configContext } from '../../modules/config'
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'
import { styled } from '@mui/material/styles'

const T = styled(Typography)(({ theme }) => ({
  color: theme.palette.common.white,
}))

export default () => {
  const { REACT_APP_TECHNICAL_CONTACT } = useContext(configContext)

  return (
    <Grid container spacing={2}>
      <Grid item xs={12}>
        <Typography variant="h5">Contact us</Typography>
      </Grid>
      <Grid item xs={12}>
        <T variant="body1">Model enquiries</T>
        <T variant="body2">{REACT_APP_TECHNICAL_CONTACT.replace('@', ' [ at ] ')}</T>
      </Grid>
      <Grid item xs={12}>
        <T variant="body1">Bugs / technical support</T>
        <T variant="body2">https://github.com/SAEON/somisana/issues</T>
      </Grid>
    </Grid>
  )
}
