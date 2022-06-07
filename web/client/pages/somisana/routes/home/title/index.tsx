import Translate from '../../../../../modules/i18n/translate'
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'
import { alpha } from '@mui/material/styles'
import Fade from '@mui/material/Fade'

const Title = () => {
  return (
    <Fade key="home" in>
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
            <Translate contentId="/home_h2" />
          </Typography>
        </Grid>
      </Grid>
    </Fade>
  )
}

export default Title
