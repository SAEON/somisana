import { useState, useContext } from 'react'
import { context as modelContext } from '../../_context'
import IconButton from '@mui/material/IconButton'
import { About as AboutIcon } from '../../../../components/icons'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import Typography from '@mui/material/Typography'
import Paper from '@mui/material/Paper'
import Draggable from 'react-draggable'
import Tooltip from '@mui/material/Tooltip'
import { Link } from '@mui/material'

const idToRegion = {
  1: 'algoa-bay',
  2: 'sw-cape'
}

const PaperComponent = props => (
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
    contact: model => `${model.creator}: ${model.creatorContactEmail.replace(/@/, ' [ at ] ')}`,
  }).sort(([a], [b]) => {
    if (a > b) return 1
    if (a < b) return -1
    return 0
  })
)

export default () => {
  const [open, setOpen] = useState(false)
  const {
    model: { title, description, _id: id, ...model },
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
          <AboutIcon
            sx={{
              color: theme => (open ? theme.palette.success.dark : 'primary'),
            }}
            fontSize="small"
          />
        </IconButton>
      </Tooltip>

      <Dialog
        sx={{ opacity: 0.8 }}
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
          <Typography
            component={Link}
            target="_blank"
            rel="noopener noreferrer"
            href={`https://mnemosyne.somisana.ac.za/somisana/${idToRegion[id]}/5-day-forecast`}
            gutterBottom
          >
            Validation report
          </Typography>
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
