import { Suspense, lazy } from 'react'
import Typography from '@mui/material/Typography'
import Grid from '@mui/material/Grid'
import { Link } from './_components'
import Div from '../../components/div'

const SiteSettings = lazy(() => import('./site-settings'))

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
          .map(props => (
            <Grid item xs={12} key={props.label}>
              <Link {...props} />
            </Grid>
          ))}
        <Div
          sx={{
            display: 'flex',
            alignItems: 'center',
          }}
        >
          <Suspense fallback={null}>
            <SiteSettings />
          </Suspense>
        </Div>
      </Grid>
    </Grid>
  )
}
