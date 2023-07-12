import { Link as RouterLink, useMatch } from 'react-router-dom'
import MuiLink from '@mui/material/Link'
import Div from '../../components/div'
import MuiIcon from '@mui/material/Icon'
import Typography from '@mui/material/Typography'

export const Link = ({ label, Icon, href, to }) => {
  const match = useMatch(to)
  const isActive = Boolean(match)

  return (
    <Div
      sx={{
        display: 'flex',
        alignItems: 'center',
      }}
    >
      <MuiIcon
        sx={{
          marginRight: theme => theme.spacing(1),
          color: theme => theme.palette.common.white,
        }}
        component={Icon}
        fontSize="small"
      />
      <Typography
        component={props => (
          <MuiLink
            sx={{
              color: theme => (isActive ? theme.palette.primary.main : theme.palette.common.white),
            }}
            {...props}
            to={href ? undefined : to}
            href={href}
            rel={href && 'noopener noreferrer'}
            target={href && '_blank'}
            component={href ? 'a' : RouterLink}
            key={label}
          >
            {label}
          </MuiLink>
        )}
        variant="overline"
      >
        {label}
      </Typography>
    </Div>
  )
}
