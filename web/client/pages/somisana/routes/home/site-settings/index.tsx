import { useState, useContext, useEffect, Suspense, lazy } from 'react'
import { ctx as siteSettingsContext } from '../../../../../modules/site-settings'
import Tooltip from '@mui/material/Tooltip'
import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'
import IconButton from '@mui/material/IconButton'
import SwipeableDrawer from '@mui/material/SwipeableDrawer'
import Typography from '@mui/material/Typography'
import { Cog, Close, CheckAll } from '../../../../../components/icons'
import Loading from '../../../../../components/loading'
import Button from '@mui/material/Button'

const DrawerContent = lazy(() => import('./_drawer-content'))

const SiteSettingsPanel = () => {
  const { updateSetting, ...settings } = useContext(siteSettingsContext)
  const [open, setOpen] = useState(false)

  useEffect(() => {
    if (!settings.accepted) {
      setOpen(true)
    }
  }, [settings.accepted])

  return (
    <>
      {/* TOGGLE DRAWER */}
      <Tooltip placement="left" title="Site settings">
        <IconButton
          onClick={() => setOpen(true)}
          size="medium"
          sx={{ position: 'absolute', bottom: 0, right: 0, margin: theme => theme.spacing(2) }}
        >
          <Cog />
        </IconButton>
      </Tooltip>

      {/* DRAWER */}
      <SwipeableDrawer
        sx={{
          display: 'flex',
        }}
        variant="temporary"
        ModalProps={{
          keepMounted: true,
        }}
        anchor="right"
        open={open}
        onClose={() => setOpen(false)}
        onOpen={() => setOpen(true)}
      >
        <AppBar elevation={0} variant="outlined" position="relative">
          <Toolbar
            disableGutters
            sx={{
              padding: theme => theme.spacing(1),
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <Typography>Site settings</Typography>
            <IconButton color='inherit' onClick={() => setOpen(false)} size="small">
              <Close />
            </IconButton>
          </Toolbar>
        </AppBar>

        <Suspense fallback={<Loading />}>
          <DrawerContent />
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
              color="primary"
              onClick={() => {
                setOpen(false)
                updateSetting({ accepted: true })
              }}
              variant="contained"
              size="medium"
              startIcon={<CheckAll />}
            >
              Accept
            </Button>
          </Toolbar>
        </AppBar>
      </SwipeableDrawer>
    </>
  )
}

export default SiteSettingsPanel
