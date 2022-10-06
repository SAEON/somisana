import { useState } from 'react'
import Tooltip from '@mui/material/Tooltip'
import Button from '@mui/material/Button'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import Typography from '@mui/material/Typography'
import { Cog as CogIcon } from '../../../../../../../../components/icons'

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
