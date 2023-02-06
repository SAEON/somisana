import { useContext, Suspense, lazy } from 'react'
import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'
import IconButton from '@mui/material/IconButton'
import Typography from '@mui/material/Typography'
import { Close, CheckAll } from '../../../components/icons'
import { Linear as Loading } from '../../../components/loading'
import Button from '@mui/material/Button'
import Fade from '@mui/material/Fade'
import { context as siteSettingsContext } from '../_provider'

const DrawerContent = lazy(() => import('./_drawer-content'))

export default ({ forceLanguage, setOpen }) => {
  const { updateSetting } = useContext(siteSettingsContext)

  return (
    <>
      <AppBar elevation={0} variant="outlined" position="relative">
        <Toolbar
          variant="dense"
          disableGutters
          sx={{
            padding: theme => theme.spacing(1),
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <Typography>Site settings</Typography>
          <IconButton color="inherit" onClick={() => setOpen(false)} size="small">
            <Close />
          </IconButton>
        </Toolbar>
      </AppBar>

      <Suspense
        fallback={
          <Loading
            sx={theme => ({
              [theme.breakpoints.up('sm')]: {
                display: 'block',
                width: 400,
              },
            })}
          />
        }
      >
        <Fade in key="lazy-loaded-drawer-content">
          <DrawerContent
            forceLanguage={forceLanguage}
            sx={theme => ({
              overflow: 'auto',
              height: '100%',
              [theme.breakpoints.up('sm')]: {
                maxWidth: 400,
              },
            })}
          />
        </Fade>
      </Suspense>

      <AppBar elevation={0} variant="outlined" position="relative" sx={{ marginTop: 'auto' }}>
        <Toolbar
          disableGutters
          variant="dense"
          sx={{
            padding: theme => theme.spacing(1),
            display: 'flex',
            alignItems: 'center',
            flexDirection: 'row-reverse',
            marginTop: 'auto',
          }}
        >
          <Button
            color="inherit"
            onClick={() => {
              updateSetting({ accepted: true })
              setOpen(false)
            }}
            variant="text"
            size="small"
            startIcon={<CheckAll />}
          >
            Accept
          </Button>
        </Toolbar>
      </AppBar>
    </>
  )
}
