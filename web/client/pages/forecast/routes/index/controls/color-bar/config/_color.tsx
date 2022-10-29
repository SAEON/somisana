import { useRef, useEffect, useCallback } from 'react'
import * as d3 from 'd3'
import Select from '@mui/material/Select'
import MenuItem from '@mui/material/MenuItem'
import ListSubheader from '@mui/material/ListSubheader'
import Canvas from '../../../../../../../components/canvas'
import Tooltip from '@mui/material/Tooltip'

// https://observablehq.com/@d3/color-schemes

const color = (name, min, max) =>
  d3.scaleSequential(d3[`interpolate${name}`]).domain(d3.extent([min || 10, max || 25], v => v))

export const presets = {
  'Sequential (Single-Hue)': ['Blues', 'Greens', 'Greys', 'Oranges', 'Purples', 'Reds'],
  'Sequential (Multi-Hue)': [
    'BuGn',
    'BuPu',
    'GnBu',
    'OrRd',
    'PuBuGn',
    'PuBu',
    'PuRd',
    'RdPu',
    'YlGnBu',
    'YlGn',
    'YlOrBr',
    'YlOrRd',
    'Cividis',
    'Viridis',
    'Inferno',
    'Magma',
    'Plasma',
    'Warm',
    'Cool',
    'CubehelixDefault',
    'Turbo',
  ],
  Diverging: ['BrBG', 'PRGn', 'PiYG', 'PuOr', 'RdBu', 'RdGy', 'RdYlBu', 'RdYlGn', 'Spectral'],
  Cyclical: ['Rainbow', 'Sinebow'],
}

const Swatch = ({ colorScheme: name, min, max }) => {
  const N = 20
  const step = (max - min) / N
  const ref = useRef(null)
  const colorFn = useCallback(color(name, min, max), [])

  useEffect(() => {
    const canvas = ref.current
    const context = canvas.getContext('2d')
    const w = canvas.width / N

    for (let i = 0; i <= N; ++i) {
      context.fillStyle = colorFn(min + i * step)
      context.fillRect(i * w, 0, w, canvas.height)
    }
  }, [])

  return (
    <Tooltip title={name} placement="right">
      <Canvas ref={ref} sx={{ width: '100%', height: '100%' }} />
    </Tooltip>
  )
}

export const SelectControl = ({ colorScheme, setColorScheme, min, max }) => {
  return (
    <Select
      size="small"
      IconComponent={null}
      labelId="select-color-label"
      id="select-color"
      value={colorScheme}
      label="Colors"
      renderValue={value => value}
      onChange={({ target: { value } }) => setColorScheme(value)}
    >
      <ListSubheader>Sequential (Single-Hue)</ListSubheader>
      {presets['Sequential (Single-Hue)'].map(colorScheme => {
        return (
          <MenuItem
            key={colorScheme}
            value={colorScheme}
            sx={{ backgroundColor: 'transparent', height: theme => theme.spacing(4) }}
          >
            <Swatch colorScheme={colorScheme} min={min} max={max} />
          </MenuItem>
        )
      })}
      <ListSubheader>Sequential (Multi-Hue)</ListSubheader>
      {presets['Sequential (Multi-Hue)'].map(colorScheme => (
        <MenuItem
          key={colorScheme}
          value={colorScheme}
          sx={{ backgroundColor: 'transparent', height: theme => theme.spacing(4) }}
        >
          <Swatch colorScheme={colorScheme} min={min} max={max} />
        </MenuItem>
      ))}
      <ListSubheader>Diverging</ListSubheader>
      {presets['Diverging'].map(colorScheme => (
        <MenuItem
          key={colorScheme}
          value={colorScheme}
          sx={{ backgroundColor: 'transparent', height: theme => theme.spacing(4) }}
        >
          <Swatch colorScheme={colorScheme} min={min} max={max} />
        </MenuItem>
      ))}
      <ListSubheader>Cyclical</ListSubheader>
      {presets['Cyclical'].map(colorScheme => (
        <MenuItem
          key={colorScheme}
          value={colorScheme}
          sx={{ backgroundColor: 'transparent', height: theme => theme.spacing(4) }}
        >
          <Swatch colorScheme={colorScheme} min={min} max={max} />
        </MenuItem>
      ))}
    </Select>
  )
}

export default color
