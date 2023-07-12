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
        onClick={e => setAnchorEl(e.currentTarget)}
        color="inherit"
        size="small"
      >
        <MenuIcon fontSize="small" />
      </IconButton>

      <Menu
        disableScrollLock
        id="navigation-menu"
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={() => setAnchorEl(null)}
        MenuListProps={{
          'aria-labelledby': 'basic-button',
        }}
      >
        {routes.map(({ includeInNavMenu, ...props }) => {
          if (!includeInNavMenu) return null

          return <NavItem key={props.label} onClick={() => setAnchorEl(null)} {...props} />
        })}
      </Menu>
    </>
  )
}
