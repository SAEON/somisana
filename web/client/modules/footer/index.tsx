import { useMemo, useContext } from 'react'
import { context as bgContext } from '../../modules/background'
import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'
import Typography from '@mui/material/Typography'
import Container from '@mui/material/Container'
import PageRoutes from './_page-routes'
import Legal from './_legal'
import Grid from '@mui/material/Grid'
import Contact from './_contact'
import SourceCode from './_source-code'
import Link from '@mui/material/Link'
import Div from '../../components/div'

export default ({ routes }) => {
  const _routes = useMemo(() => routes.filter(({ includeInFooter }) => includeInFooter), [routes])
  const backgroundImage = useContext(bgContext)
  const [photographer, unsplashId] = backgroundImage.image
    .replace('/bg/', '')
    .replace(/-unsplash.*/, '')
    .split('~')

  return (
    <Div sx={{ position: 'relative' }}>
      <AppBar
        variant="outlined"
        elevation={0}
        position="relative"
        sx={{ backgroundColor: theme => theme.palette.grey[800] }}
      >
        {/* MAIN */}
        <Toolbar
          sx={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'flex-start',
          }}
        >
          <Container
            sx={{ paddingTop: theme => theme.spacing(4), paddingBottom: theme => theme.spacing(4) }}
          >
            <Grid container spacing={4}>
              <Grid container item xs={12} sm={3}>
                <PageRoutes routes={_routes} />
              </Grid>
              <Grid container item xs={12} sm={3}>
                <Legal routes={_routes} />
              </Grid>
              <Grid item xs={12} sm={3}>
                <Contact />
              </Grid>
              <Grid container item xs={12} sm={3}>
                <SourceCode routes={_routes} />
              </Grid>
            </Grid>
          </Container>

          {/* BG IMAGE ATTRIBUTION */}
          <Link
            target="_blank"
            rel="noopener noreferrer"
            href={`https://unsplash.com/photos/${unsplashId}`}
            sx={{
              placeSelf: 'end',
              fontSize: '0.75rem',
              margin: theme => `0 ${theme.spacing(1)} ${theme.spacing(1)} 0`,
              color: theme => theme.palette.common.white,
            }}
            variantMapping={{ overline: 'p' }}
          >
            Photo by{' '}
            {photographer
              .split('-')
              .map(s => s.capitalize())
              .join(' ')}{' '}
            - unsplash.com
          </Link>
        </Toolbar>

        {/* COPYRIGHT */}
        <Toolbar
          variant="dense"
          sx={theme => ({ backgroundColor: theme.palette.grey[900], minHeight: theme.spacing(1) })}
        >
          <Container style={{ display: 'flex', justifyContent: 'center' }}>
            <Typography variant="overline" variantMapping={{ overline: 'p' }}>
              © SAEON 2020 - {new Date().getFullYear()}
            </Typography>
          </Container>
        </Toolbar>
      </AppBar>
    </Div>
  )
}
