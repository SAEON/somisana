import Translate from '..'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import DialogContentText from '@mui/material/DialogContentText'
import DialogActions from '@mui/material/DialogActions'
import Button from '@mui/material/Button'

export default ({ open, setOpen, from }) => {
  return (
    <Dialog onClose={() => setOpen(false)} open={open}>
      <DialogTitle>
        <Translate contentId="Language translation" />
      </DialogTitle>
      <DialogContent dividers>
        <DialogContentText gutterBottom>
          <Translate contentId="suggest-translation" />:
        </DialogContentText>
        <DialogContentText gutterBottom>From: {from}</DialogContentText>
        <DialogContentText gutterBottom>To: (TODO - this should be a text field)</DialogContentText>
      </DialogContent>
      <DialogActions>
        <Button size="small" variant="contained">
          TODO
        </Button>
      </DialogActions>
    </Dialog>
  )
}
