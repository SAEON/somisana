import { useState } from 'react'
import IconButton from '@mui/material/IconButton'
import Menu from '@mui/material/Menu'
import { Account as UserIcon } from '../../../../components/icons'
import Logout from './_logout'
import Div from '../../../../components/div'

export default props => {
  const [anchor, setAnchor] = useState(null)

  const onClose = () => setAnchor(null)
  const onOpen = e => setAnchor(e.currentTarget)

  return (
    <Div>
      {/* MENU TRIGGER */}
      <IconButton onClick={onOpen} size="small">
        <UserIcon fontSize="small" />
      </IconButton>

      {/* MENU */}
      <Menu
        disableScrollLock
        id="simple-menu"
        anchorEl={anchor}
        keepMounted
        open={Boolean(anchor)}
        onClose={onClose}
      >
        <Logout />
      </Menu>
    </Div>
  )
}
