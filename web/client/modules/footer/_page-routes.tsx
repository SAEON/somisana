import Typography from '@mui/material/Typography'
import Grid from '@mui/material/Grid'
import { Link as RouterLink } from 'react-router-dom'
import Link from '@mui/material/Link'
import Div from '../../components/div'
import MuiIcon from '@mui/material/Icon'

export default ({ routes }) => {
  return (
    <Grid container spacing={2} sx={{ alignContent: 'flex-start' }}>
      <Grid item xs={12}>
        <Typography variant="h5">Quick links</Typography>
      </Grid>
      <Grid container item xs={12}>
        {routes
          .filter(({ group }) => {
            if (group === 'legal') return false
            if (group === 'source code') return false

            return true
          })
          .map(({ label, Icon, href, to }) => (
            <Grid item xs={12} key={label}>
              <Div
                sx={{
                  display: 'flex',
                  alignItems: 'center',
                }}
              >
                <MuiIcon
                  sx={{
                    mr: theme => theme.spacing(1),
                  }}
                  component={Icon}
                  fontSize="small"
                />
                <Typography
                  component={props => (
                    <Link
                      sx={{
                        color: theme => theme.palette.common.white,
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
                    </Link>
                  )}
                  variant="overline"
                >
                  {label}
                </Typography>
              </Div>
            </Grid>
          ))}
      </Grid>
    </Grid>
  )
}
