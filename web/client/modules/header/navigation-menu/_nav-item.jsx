import { forwardRef } from 'react'
import { Link, Route } from 'react-router-dom'
import MenuItem from '@mui/material/MenuItem'
import ListItemIcon from '@mui/material/ListItemIcon'
import ListItemText from '@mui/material/ListItemText'

export default forwardRef(({ onClick, label, to, Icon, exact = false, href }, ref) => {
  return (
    <Route path={to} exact={exact}>
      {({ match }) => {
        return (
          <MenuItem
            ref={ref}
            component={href ? 'a' : Link}
            active={match}
            rel={href && 'noopener noreferrer'}
            target={href && '_blank'}
            onClick={onClick}
            to={to || ''}
            href={href}
          >
            <ListItemIcon>{<Icon color={match ? 'primary' : 'inherit'} />}</ListItemIcon>
            <ListItemText primary={label} />
          </MenuItem>
        )
      }}
    </Route>
  )
})
