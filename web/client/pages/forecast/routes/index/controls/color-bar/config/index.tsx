import { useState } from 'react'
import Tooltip from '@mui/material/Tooltip'
import IconButton from '@mui/material/IconButton'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import { Cog as CogIcon } from '../../../../../../../components/icons'
import Q from '../../../../../../../components/quick-form'
import TextField from '@mui/material/TextField'
import Paper, { PaperProps } from '@mui/material/Paper'
import Draggable from 'react-draggable'
import FormControl from '@mui/material/FormControl'
import InputLabel from '@mui/material/InputLabel'
import debounce from '../../../../../../../lib/debounce'

import { default as _color, SelectControl } from './_color'

export const color = _color

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
            <SelectControl
              min={scaleMin}
              max={scaleMax}
              colorScheme={colorScheme}
              setColorScheme={setColorScheme}
            />
          </FormControl>
          <Q
            effects={debounce(({ _scaleMin, _scaleMax }) => {
              const min =
                typeof _scaleMin === 'number' ? _scaleMin : parseFloat(_scaleMin.replace(/,/g, '.'))
              const max =
                typeof _scaleMax === 'number' ? _scaleMax : parseFloat(_scaleMax.replace(/,/g, '.'))

              if (!isNaN(min) && !isNaN(max) && max >= min) {
                setScaleMin(min)
                setScaleMax(max)
              }
            }, 500)}
            _scaleMin={scaleMin}
            _scaleMax={scaleMax}
          >
            {(update, { _scaleMin, _scaleMax }) => (
              <>
                <TextField
                  sx={{ flex: 2 }}
                  fullWidth
                  variant="outlined"
                  label="Min"
                  type="number"
                  margin="normal"
                  size="small"
                  value={_scaleMin}
                  placeholder="Auto"
                  onChange={({ target: { value: _scaleMin } }) => update({ _scaleMin })}
                />
                <TextField
                  sx={{ flex: 2 }}
                  fullWidth
                  variant="outlined"
                  label="Max"
                  type="number"
                  margin="normal"
                  size="small"
                  value={_scaleMax}
                  placeholder="Auto"
                  onChange={({ target: { value: _scaleMax } }) => update({ _scaleMax })}
                />
              </>
            )}
          </Q>
        </DialogContent>
      </Dialog>
    </>
  )
}
