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
import FormControl from '@mui/material/FormControl'
import InputLabel from '@mui/material/InputLabel'
import Select from '@mui/material/Select'
import MenuItem from '@mui/material/MenuItem'
export { default as color } from './_color'

const PaperComponent = (props: PaperProps) => (
  <Draggable handle="#draggable-dialog-title" cancel={'[class*="MuiDialogContent-root"]'}>
    <Paper {...props} />
  </Draggable>
)

export default ({ scaleMin, scaleMax, setScaleMin, setScaleMax, colorScheme, setColorScheme }) => {
  const [open, setOpen] = useState(false)

  const title = 'Colour range configuration'

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
          <FormControl fullWidth>
            <InputLabel id="select-color-label">Colors</InputLabel>
            <Select
              size="small"
              IconComponent={null}
              labelId="select-color-label"
              id="select-color"
              value={colorScheme}
              label="Colors"
              onChange={({ target: { value } }) => setColorScheme(value)}
            >
              <MenuItem value={'Warm'}>Warm</MenuItem>
              <MenuItem value={'Cool'}>Cool</MenuItem>
              <MenuItem value={'Magma'}>Magma</MenuItem>
            </Select>
          </FormControl>

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
