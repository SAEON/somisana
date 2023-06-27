import Typography from '@mui/material/Typography'
import Grid from '@mui/material/Grid'
import { Link } from './_components'

export default ({ routes }) => {
  return (
    <Grid container spacing={2} sx={{ alignContent: 'flex-start' }}>
      <Grid item xs={12}>
        <Typography variant="h5">Legal</Typography>
      </Grid>
      <Grid container item xs={12}>
        {routes
          .filter(({ group }) => group === 'legal')
          .map(props => (
            <Grid item xs={12} key={props.label}>
              <Link {...props} />
            </Grid>
          ))}
      </Grid>
    </Grid>
  )
}
