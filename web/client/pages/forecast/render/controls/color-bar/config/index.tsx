import { useState, useContext } from 'react'
import { context as modelContext } from '../../../_context'
import Tooltip from '@mui/material/Tooltip'
import IconButton from '@mui/material/IconButton'
import Dialog from '@mui/material/Dialog'
import DialogTitle from '@mui/material/DialogTitle'
import DialogContent from '@mui/material/DialogContent'
import { Cog as CogIcon } from '../../../../../../components/icons'
import Q from '../../../../../../components/quick-form'
import TextField from '@mui/material/TextField'
import Paper, { PaperProps } from '@mui/material/Paper'
import Draggable from 'react-draggable'
import FormControl from '@mui/material/FormControl'
import InputLabel from '@mui/material/InputLabel'
import debounce from '../../../../../../lib/debounce'
import Switch from '@mui/material/Switch'
import FormGroup from '@mui/material/FormGroup'
import FormControlLabel from '@mui/material/FormControlLabel'

import { default as _color, SelectControl } from './_color'

export const color = _color

const PaperComponent = (props: PaperProps) => (
  <Draggable handle="#draggable-dialog-title" cancel={'[class*="MuiDialogContent-root"]'}>
    <Paper {...props} />
  </Draggable>
)

export default () => {
  const {
    scaleMin,
    scaleMax,
    setScaleMin,
    setScaleMax,
    colorScheme,
    setColorScheme,
    thresholds,
    setThresholds,
    showIsolines,
    setShowIsolines,
    reverseColors,
    setReverseColors,
  } = useContext(modelContext)
  const [open, setOpen] = useState(false)

  const title = 'Colour range configuration'

  return (
    <>
      <Tooltip placement="right-start" title="Configure scale and range">
        <IconButton size="small" color="primary" onClick={() => setOpen(!open)}>
          <CogIcon
            sx={{
              color: theme => (open ? theme.palette.success.dark : 'primary'),
            }}
            fontSize="small"
          />
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
              colorScheme={colorScheme}
              setColorScheme={setColorScheme}
              min={scaleMin}
              max={scaleMax}
            />
          </FormControl>
          <FormGroup
            sx={{
              pt: 1,
            }}
          >
            <FormControlLabel
              sx={{
                display: 'flex',
                flexDirection: 'row-reverse',
                justifyContent: 'flex-start',
                margin: 0,
              }}
              control={
                <Switch
                  sx={{ margin: theme => `0 0 0 ${theme.spacing(2)}` }}
                  checked={reverseColors}
                  onChange={() => setReverseColors(b => !b)}
                />
              }
              label="Reverse"
            />
          </FormGroup>
          <FormGroup
            sx={{
              pt: 1,
            }}
          >
            <FormControlLabel
              sx={{
                display: 'flex',
                flexDirection: 'row-reverse',
                justifyContent: 'flex-start',
                margin: 0,
              }}
              control={
                <Switch
                  sx={{ marginLeft: 2 }}
                  checked={showIsolines}
                  onChange={() => setShowIsolines(b => !b)}
                />
              }
              label="Show isolines"
            />
          </FormGroup>
          <Q
            effects={debounce(({ _scaleMin, _scaleMax, _thresholds }) => {
              const ts =
                typeof _thresholds === 'number'
                  ? _thresholds
                  : parseFloat(_thresholds.replace(/,/g, '.'))
              const min =
                typeof _scaleMin === 'number' ? _scaleMin : parseFloat(_scaleMin.replace(/,/g, '.'))
              const max =
                typeof _scaleMax === 'number' ? _scaleMax : parseFloat(_scaleMax.replace(/,/g, '.'))

              if (!isNaN(min) && !isNaN(max) && max >= min) {
                if (scaleMin !== min) setScaleMin(min)
                if (scaleMax !== max) setScaleMax(max)
              }

              if (!isNaN(ts) && ts !== thresholds) {
                setThresholds(ts)
              }
            }, 500)}
            _scaleMin={scaleMin}
            _scaleMax={scaleMax}
            _thresholds={thresholds}
          >
            {(update, { _scaleMin, _scaleMax, _thresholds }) => (
              <>
                <TextField
                  sx={{ flex: 2 }}
                  fullWidth
                  variant="outlined"
                  label="Thresholds"
                  type="number"
                  margin="normal"
                  size="small"
                  value={_thresholds}
                  placeholder="Auto"
                  onChange={({ target: { value: _thresholds } }) => update({ _thresholds })}
                />
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
