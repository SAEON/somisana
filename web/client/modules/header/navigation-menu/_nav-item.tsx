import { Link, useMatch } from 'react-router-dom'
import MenuItem from '@mui/material/MenuItem'
import ListItemIcon from '@mui/material/ListItemIcon'
import ListItemText from '@mui/material/ListItemText'
import Typography from '@mui/material/Typography'

export default ({ onClick, label, to, Icon, href }) => {
  const match = useMatch(to)
  const isActive = Boolean(match)

  return (
    <MenuItem
      dense
      component={Link}
      rel={href && 'noopener noreferrer'}
      target={href && '_blank'}
      onClick={onClick}
      to={to || ''}
      href={href}
    >
      <ListItemIcon>{<Icon color={isActive ? 'primary' : 'inherit'} />}</ListItemIcon>
      <ListItemText
        primary={<Typography color={isActive ? 'primary' : 'inherit'}>{label}</Typography>}
      />
    </MenuItem>
  )
}
