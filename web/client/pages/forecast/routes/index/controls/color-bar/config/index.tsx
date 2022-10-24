import { useState } from 'react'
import Tooltip from '@mui/material/Tooltip'
import IconButton from '@mui/material/IconButton'
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

// https://observablehq.com/@d3/color-schemes

export default ({ scaleMin, scaleMax, setScaleMin, setScaleMax, colorScheme, setColorScheme }) => {
  const [open, setOpen] = useState(false)

  const title = 'Colour scale'

  return (
    <>
      <Tooltip placement="right-start" title="Configure scale and range">
        <IconButton
          sx={{ alignSelf: 'center', mb: theme => theme.spacing(1) }}
          size="small"
          color="primary"
          onClick={() => setOpen(!open)}
        >
          <CogIcon fontSize="small" />
        </IconButton>
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
