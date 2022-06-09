import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'
import ElevationOnScroll from './animations/elevation-on-scroll'
import NavigationMenu from './navigation-menu'
import Breadcrumbs from './breadcrumbs'

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
            opacity: 0.8,
          }}
          position="fixed"
          color="inherit"
        >
          <Toolbar disableGutters sx={{ px: theme => theme.spacing(1) }} variant="dense" {...props}>
            {/* NAVIGATION MENU */}
            <NavigationMenu routes={routes} />

            {/* BREADCRUMBS */}
            <Breadcrumbs />

            {children}
          </Toolbar>
        </AppBar>
      </ElevationOnScroll>

      {/* PUSH CONTENT DOWN */}
      <Toolbar variant="dense" />
    </>
  )
}

export default Header
