import { useState } from 'react'
import Tooltip from '@mui/material/Tooltip'
import Button from '@mui/material/Button'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import Typography from '@mui/material/Typography'
import { Cog as CogIcon } from '../../../../../../../../components/icons'
import Div from '../../../../../../../../components/div'
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
          <Typography variant="caption">Color range</Typography>
          <Div sx={{ display: 'flex' }}>
            <TextField
              sx={{ flex: 2 }}
              variant="outlined"
              label="Min"
              type="number"
              margin="normal"
              size="small"
              value={scaleMin}
              placeholder="Auto"
              onChange={({ target: { value } }) => setScaleMin(parseFloat(value))}
            />
            <Div sx={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              -
            </Div>
            <TextField
              sx={{ flex: 2 }}
              variant="outlined"
              label="Max"
              type="number"
              margin="normal"
              size="small"
              value={scaleMax}
              placeholder="Auto"
              onChange={({ target: { value } }) => setScaleMax(parseFloat(value))}
            />
          </Div>

          <Typography gutterBottom>
            Not implemented yet. Should be possible to specify manual or auto intervals, save
            settings to browser storage so that settings are persisted across page visits, change
            color scheme
          </Typography>
        </DialogContent>
      </Dialog>
    </>
  )
}
