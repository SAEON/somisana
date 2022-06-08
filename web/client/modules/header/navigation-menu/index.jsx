import { useState } from 'react'
import IconButton from '@mui/material/IconButton'
import Menu from '@mui/material/Menu'
import { Menu as MenuIcon } from '../../../components/icons'
import NavItem from './_nav-item'

export default ({ routes }) => {
  const [anchorEl, setAnchorEl] = useState(null)

  return (
    <>
      <IconButton
        aria-label="Show navigation menu"
        onClick={e => setAnchorEl(anchorEl ? null : e.currentTarget)}
        color="inherit"
        size="large"
      >
        <MenuIcon />
      </IconButton>

      <Menu
        id="site-navigation-menu"
        anchorEl={anchorEl}
        disableScrollLock
        keepMounted
        open={Boolean(anchorEl)}
        onClose={() => setAnchorEl(null)}
      >
        {routes
          .filter(({ requiredPermission = false, excludeFromNav = false }) => {
            if (excludeFromNav) {
              return false
            }

            return true // refer to data portal for auth
          })
          .map(({ label, Icon, to, href }) => {
            if (!Icon) {
              throw new Error('Cannot draw menu item without an Icon')
            }

            return (
              <NavItem
                onClick={() => setAnchorEl(null)}
                href={href}
                key={label}
                Icon={Icon}
                label={label}
                to={to}
              />
            )
          })}
      </Menu>
    </>
  )
}
