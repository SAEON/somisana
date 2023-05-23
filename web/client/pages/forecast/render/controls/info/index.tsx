import { useState, useContext } from 'react'
import { context as modelContext } from '../../_context'
import IconButton from '@mui/material/IconButton'
import { About as AboutIcon } from '../../../../../components/icons'
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

const showFields = Object.fromEntries(
  Object.entries({
    max_x: undefined,
    max_y: undefined,
    min_x: undefined,
    min_y: undefined,
    gridWidth: undefined,
    gridHeight: undefined,
    contact: model =>
      `${model.creator}: ${model.creatorContactEmail.replace(/\./g, '[dot]').replace(/@/, '[at]')}`,
  }).sort(([a], [b]) => {
    if (a > b) return 1
    if (a < b) return -1
    return 0
  })
)

export default () => {
  const [open, setOpen] = useState(false)
  const {
    model: { title, description, ...model },
  } = useContext(modelContext)

  return (
    <>
      <Tooltip placement="left-start" title="About this forecast">
        <IconButton
          size="small"
          color="primary"
          onClick={() => {
            globalThis.dispatchEvent(
              new CustomEvent('interaction', {
                detail: { value: !open, type: 'info-toggle' },
              })
            )
            setOpen(!open)
          }}
        >
          <AboutIcon fontSize="small" />
        </IconButton>
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
          <pre>
            {Object.entries(showFields)
              .map(([field, render]) => {
                return `${field}: ${render?.(model, field) || model[field]}`
              })
              .join('\n')}
          </pre>
        </DialogContent>
      </Dialog>
    </>
  )
}
