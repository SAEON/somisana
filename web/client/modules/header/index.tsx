import { useState } from 'react'
import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'
import Tooltip from '@mui/material/Tooltip'
import IconButton from '@mui/material/IconButton'
import { Menu as MenuIcon } from '../../components/icons'
import Menu from '@mui/material/Menu'
import MenuItem from '@mui/material/MenuItem'
import Link from '@mui/material/Link'

const Header = ({ children, ...props }) => {
  const [anchorEl, setAnchorEl] = useState(false)

  const open = Boolean(anchorEl)
  const handleClick = event => {
    setAnchorEl(event.currentTarget)
  }
  const handleClose = () => {
    setAnchorEl(null)
  }

  return (
    <>
      {/* SIDE MENU */}
      <Menu
        id="navigation-menu"
        anchorEl={anchorEl}
        open={open}
        onClose={handleClose}
        MenuListProps={{
          'aria-labelledby': 'basic-button',
        }}
      >
        <MenuItem>
          <Link href="/algoa-bay-forecast">Algoa Bay forecast</Link>
        </MenuItem>
        <MenuItem>
          <Link href="/false-bay-forecast">False Bay forecast</Link>
        </MenuItem>
        <MenuItem>
          <Link href="/map">Interactive map</Link>
        </MenuItem>
      </Menu>

      {/* HEADER */}
      <AppBar elevation={0} position="fixed" variant="outlined" color="inherit">
        <Toolbar disableGutters sx={{ px: theme => theme.spacing(1) }} variant="dense" {...props}>
          {/* TOGGLE DRAWER */}
          <Tooltip placement="right" title="Navigation menu">
            <IconButton onClick={handleClick} size="medium">
              <MenuIcon />
            </IconButton>
          </Tooltip>

          {children}
        </Toolbar>
      </AppBar>
    </>
  )
}

export default Header
