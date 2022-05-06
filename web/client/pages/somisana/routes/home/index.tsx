import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'
import { alpha } from '@mui/material/styles'

const Home = () => {
  return (
    <Grid
      sx={{
        height: '100vh',
        alignContent: 'center',
        justifyContent: 'center',
      }}
      container
    >
      <Grid item xs={12} sm={12} md={8} xl={6}>
        <Typography
          sx={{
            textAlign: 'center',
            color: theme => alpha(theme.palette.primary.main, 0.9),
          }}
          variant="h1"
        >
          SOMISANA
        </Typography>
        <Typography
          sx={{
            textAlign: 'center',
            color: theme => alpha(theme.palette.primary.main, 0.9),
          }}
          variant="h5"
          variantMapping={{
            h5: 'h2',
          }}
        >
          Sustainable Ocean Modelling Initiative: A South African Approach
        </Typography>
      </Grid>
    </Grid>
  )
}

export default Home
