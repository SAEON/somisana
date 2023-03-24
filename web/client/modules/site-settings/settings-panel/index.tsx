import Drawer from '@mui/material/Drawer'
import LazyLoader from './_lazy-loader'

export const SettingPanel = ({ forceLanguage, open, setOpen }) => {
  return (
    <Drawer
      disableScrollLock
      sx={{
        display: 'flex',
      }}
      variant="temporary"
      ModalProps={{
        keepMounted: false,
      }}
      anchor="right"
      open={open}
      onClose={() => setOpen(false)}
    >
      <LazyLoader forceLanguage={forceLanguage} setOpen={setOpen} />
    </Drawer>
  )
}

export default SettingPanel
