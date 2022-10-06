import { useState } from 'react'
import Tooltip from '@mui/material/Tooltip'
import Button from '@mui/material/Button'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import Typography from '@mui/material/Typography'
import { Cog as CogIcon } from '../../../../../../../../components/icons'
import TextField from '@mui/material/TextField'

export default ({ scaleMin, scaleMax, setScaleMin, setScaleMax }) => {
  const [open, setOpen] = useState(false)

  const title = 'Configure scale bar'

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

      <Dialog open={open} onClose={() => setOpen(false)}>
        <DialogTitle title={title}>{title}</DialogTitle>
        <DialogContent dividers>
          <TextField
            fullWidth
            variant="standard"
            label="Min"
            type="number"
            margin="normal"
            size="small"
            helperText="Minimum value to use for the color range"
            step=".01"
            value={scaleMin}
            placeholder="Auto"
            onChange={({ target: { value } }) => setScaleMin(value)}
          />
          <TextField
            fullWidth
            variant="standard"
            label="Max"
            type="number"
            margin="normal"
            size="small"
            helperText="Max value to use for the color range"
            step=".01"
            value={scaleMax}
            placeholder="Auto"
            onChange={({ target: { value } }) => setScaleMax(value)}
          />
          <Typography gutterBottom>
            Not implemented yet. Should be possible to define constant or auto min/max values,
            specify manual or auto intervals, save settings to browser storage so that settings are
            persisted across page visits, change color scheme
          </Typography>
        </DialogContent>
      </Dialog>
    </>
  )
}
