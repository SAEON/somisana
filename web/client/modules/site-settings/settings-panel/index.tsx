import { useContext, Suspense, lazy } from 'react'
import Dialog from '@mui/material/Dialog'
import Draggable from 'react-draggable'
import IconButton from '@mui/material/IconButton'
import Typography from '@mui/material/Typography'
import { Close, CheckAll } from '../../../components/icons'
import { Linear as Loading } from '../../../components/loading'
import Button from '@mui/material/Button'
import Fade from '@mui/material/Fade'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogActions from '@mui/material/DialogActions'
import Div from '../../../components/div'
import { context as siteSettingsContext } from '../_provider'

const DrawerContent = lazy(() => import('./_drawer-content'))

export const SettingPanel = ({ forceLanguage, open, setOpen }) => {
  const { updateSetting } = useContext(siteSettingsContext)

  return (
    <Dialog disableScrollLock open={open} onClose={() => setOpen(false)}>
      <DialogTitle
        component={Div}
        sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}
      >
        <Typography>Site settings</Typography>
        <IconButton color="primary" onClick={() => setOpen(false)} size="small">
          <Close fontSize="small" />
        </IconButton>
      </DialogTitle>

      <DialogContent dividers sx={{ padding: 0 }}>
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
      </DialogContent>

      <DialogActions>
        <Button
          color="primary"
          onClick={() => {
            updateSetting({ accepted: true })
            setOpen(false)
          }}
          variant="text"
          size="medium"
          startIcon={<CheckAll />}
        >
          Save
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default SettingPanel
