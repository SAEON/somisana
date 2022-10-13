import { useState } from 'react'
import Tooltip from '@mui/material/Tooltip'
import Button from '@mui/material/Button'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import { Cog as CogIcon } from '../../../../../../../components/icons'
import TextField from '@mui/material/TextField'
import Paper, { PaperProps } from '@mui/material/Paper'
import Draggable from 'react-draggable'

const PaperComponent = (props: PaperProps) => (
  <Draggable handle="#draggable-dialog-title" cancel={'[class*="MuiDialogContent-root"]'}>
    <Paper {...props} />
  </Draggable>
)

export default ({ scaleMin, scaleMax, setScaleMin, setScaleMax }) => {
  const [open, setOpen] = useState(false)

  const title = 'Colour scale'

  return (
    <>
      <Tooltip placement="right-start" title="Configure scale and range">
        <Button
          sx={{ position: 'relative', borderRadius: 0, minWidth: 'unset' }}
          onClick={() => setOpen(!open)}
        >
          <CogIcon sx={{ width: '0.8em' }} />
        </Button>
      </Tooltip>

      <Dialog
        maxWidth="xs"
        open={open}
        onClose={() => setOpen(false)}
        PaperComponent={PaperComponent}
        aria-labelledby="draggable-dialog-title"
      >
        <DialogTitle
          id="draggable-dialog-title"
          sx={{ cursor: 'move', textAlign: 'center' }}
          title={title}
        >
          {title}
        </DialogTitle>
        <DialogContent dividers>
          <TextField
            sx={{ flex: 2 }}
            fullWidth
            variant="outlined"
            label="Min"
            type="number"
            margin="normal"
            size="small"
            value={scaleMin}
            placeholder="Auto"
            onChange={({ target: { value } }) => setScaleMin(parseFloat(value))}
          />
          <TextField
            sx={{ flex: 2 }}
            fullWidth
            variant="outlined"
            label="Max"
            type="number"
            margin="normal"
            size="small"
            value={scaleMax}
            placeholder="Auto"
            onChange={({ target: { value } }) => setScaleMax(parseFloat(value))}
          />
        </DialogContent>
      </Dialog>
    </>
  )
}
