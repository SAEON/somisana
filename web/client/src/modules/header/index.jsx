import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'
import ElevationOnScroll from './animations/elevation-on-scroll'
import NavigationMenu from './navigation-menu'
import Breadcrumbs from './breadcrumbs'
import Divider from '@mui/material/Divider'
import Div from '../../components/div'
import Auth from './auth'

const Header = ({ children, routes = [], ...props }) => {
  return (
    <>
      {/* HEADER */}
      <ElevationOnScroll>
        <AppBar
          sx={{
            borderTop: 'none',
            borderLeft: 'none',
            borderRight: 'none',
            opacity: 1,
          }}
          position="fixed"
          color="inherit"
        >
          <Toolbar
            disableGutters
            sx={{ padding: theme => `0 ${theme.spacing(1)}` }}
            variant="dense"
            {...props}
          >
            <NavigationMenu routes={routes} />
            <Divider
              sx={{ margin: theme => `0 ${theme.spacing(1)}` }}
              flexItem
              orientation="vertical"
            />
            <Breadcrumbs routes={routes} />

            <Div sx={{ marginLeft: 'auto' }}>
              {children}
              <Auth />
            </Div>
          </Toolbar>
        </AppBar>
      </ElevationOnScroll>

      {/* PUSH CONTENT DOWN */}
      <Toolbar variant="dense" />
    </>
  )
}

export default Header
