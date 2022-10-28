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
  const ref = useRef(null)
  const colorFn = useCallback(color(name, 1, 5), [])

  useEffect(() => {
    const canvas = d3.select(ref.current)
    console.log(canvas)
    // .data([1, 2, 3, 4, 5])
    // .enter()
    // .style('fill', d => colorFn(d))
    console.log(canvas)
    console.log(colorFn)
  }, [])

  return (
    <Tooltip title={name} placement="left-start">
      <Canvas ref={ref} sx={{ width: '100%', height: '100%', border: '1px solid red' }} />
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
