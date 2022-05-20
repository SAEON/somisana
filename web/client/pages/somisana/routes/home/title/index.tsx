import { useContext } from 'react'
import { ctx as i18nContext } from '../../../../../modules/i18n'
import Grid from '@mui/material/Grid'
import Typography from '@mui/material/Typography'
import { alpha } from '@mui/material/styles'
import Fade from '@mui/material/Fade'

const Title = () => {
  const { t, locale } = useContext(i18nContext)

  // TODO LOCALE
  console.log('rendering', locale, t('/home_h2', locale))

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
            {t('/home_h2', locale)}
          </Typography>
        </Grid>
      </Grid>
    </Fade>
  )
}

export default Title
