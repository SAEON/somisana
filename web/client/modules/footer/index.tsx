import { useMemo } from 'react'
import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'
import Typography from '@mui/material/Typography'
import Container from '@mui/material/Container'
import PageRoutes from './_page-routes'
import Legal from './_legal'
import Grid from '@mui/material/Grid'
import Contact from './_contact'
import SourceCode from './_source-code'
import Div from '../../components/div'

export default ({ routes }) => {
  const _routes = useMemo(() => routes.filter(({ includeInFooter }) => includeInFooter), [routes])

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
