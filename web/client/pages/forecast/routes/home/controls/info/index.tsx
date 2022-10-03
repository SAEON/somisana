import { useState, useContext } from 'react'
import { context as modelContext } from '../../_context'
import IconButton from '@mui/material/IconButton'
import { About as AboutIcon } from '../../../../../../components/icons'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import Typography from '@mui/material/Typography'
import { alpha } from '@mui/system'

export default () => {
  const [open, setOpen] = useState(false)
  const {
    model: { title, description, ...model },
  } = useContext(modelContext)

  return (
    <>
      <IconButton
        size="small"
        onClick={() => setOpen(!open)}
        sx={{
          border: theme => `1px solid ${alpha(theme.palette.common.black, 0.54)}`,
          ml: theme => theme.spacing(1),
          mt: theme => theme.spacing(1),
          position: 'absolute',
        }}
      >
        <AboutIcon />
      </IconButton>

      <Dialog open={open} onClose={() => setOpen(false)}>
        <DialogTitle title={title}>{title}</DialogTitle>
        <DialogContent dividers>
          <Typography gutterBottom>{description}</Typography>
          <pre>{JSON.stringify(model, null, 2)}</pre>
        </DialogContent>
      </Dialog>
    </>
  )
}
