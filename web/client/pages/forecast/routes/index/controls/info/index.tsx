import { useState, useContext } from 'react'
import { context as modelContext } from '../../_context'
import Button from '@mui/material/Button'
import { About as AboutIcon } from '../../../../../../components/icons'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import Typography from '@mui/material/Typography'
import Paper, { PaperProps } from '@mui/material/Paper'
import Draggable from 'react-draggable'
import Tooltip from '@mui/material/Tooltip'

const PaperComponent = (props: PaperProps) => (
  <Draggable handle="#draggable-dialog-title" cancel={'[class*="MuiDialogContent-root"]'}>
    <Paper {...props} />
  </Draggable>
)

export default () => {
  const [open, setOpen] = useState(false)
  const {
    model: { title, description, ...model },
  } = useContext(modelContext)

  return (
    <>
      <Tooltip placement="left-start" title="About this forecast">
        <Button
          size="small"
          onClick={() => setOpen(!open)}
          sx={{
            borderRadius: 0,
            minWidth: 'unset',
          }}
        >
          <AboutIcon sx={{ width: '0.8em' }} />
        </Button>
      </Tooltip>

      <Dialog
        open={open}
        onClose={() => setOpen(false)}
        PaperComponent={PaperComponent}
        aria-labelledby="draggable-dialog-title"
      >
        <DialogTitle sx={{ cursor: 'move' }} title={title}>
          {title}
        </DialogTitle>
        <DialogContent dividers>
          <Typography gutterBottom>{description}</Typography>
          <pre>{JSON.stringify(model, null, 2)}</pre>
        </DialogContent>
      </Dialog>
    </>
  )
}
