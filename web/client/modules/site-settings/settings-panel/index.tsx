import {  Suspense, lazy } from 'react'
import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'
import IconButton from '@mui/material/IconButton'
import SwipeableDrawer from '@mui/material/SwipeableDrawer'
import Typography from '@mui/material/Typography'
import {  Close, CheckAll } from '../../../components/icons'
import Loading from '../../../components/loading'
import Button from '@mui/material/Button'
import Fade from '@mui/material/Fade'

const DrawerContent = lazy(() => import('./_content'))

export const SettingPanel = ({open, setOpen}) => {
  return (
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
              sx={theme => ({
                overflow: 'auto',
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
                setOpen(false)
                updateSetting({ accepted: true })
              }}
              variant="text"
              size="small"
              startIcon={<CheckAll />}
            >
              Accept
            </Button>
          </Toolbar>
        </AppBar>
      </SwipeableDrawer>
  )
}

export default SettingPanel