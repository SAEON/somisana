import * as d3 from 'd3'
import Select from '@mui/material/Select'
import MenuItem from '@mui/material/MenuItem'
import ListSubheader from '@mui/material/ListSubheader'

// https://observablehq.com/@d3/color-schemes

export default (name, min, max) =>
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

export const SelectControl = ({ colorScheme, setColorScheme }) => {
  return (
    <Select
      size="small"
      IconComponent={null}
      labelId="select-color-label"
      id="select-color"
      value={colorScheme}
      label="Colors"
      onChange={({ target: { value } }) => setColorScheme(value)}
    >
      <ListSubheader>Sequential (Single-Hue)</ListSubheader>
      {presets['Sequential (Single-Hue)'].map(value => (
        <MenuItem
          key={value}
          value={value}
          sx={{ backgroundColor: 'transparent', height: theme => theme.spacing(4) }}
        >
          {value}
        </MenuItem>
      ))}
      <ListSubheader>Sequential (Multi-Hue)</ListSubheader>
      {presets['Sequential (Multi-Hue)'].map(value => (
        <MenuItem
          key={value}
          value={value}
          sx={{ backgroundColor: 'transparent', height: theme => theme.spacing(4) }}
        >
          {value}
        </MenuItem>
      ))}
      <ListSubheader>Diverging</ListSubheader>
      {presets['Diverging'].map(value => (
        <MenuItem
          key={value}
          value={value}
          sx={{ backgroundColor: 'transparent', height: theme => theme.spacing(4) }}
        >
          {value}
        </MenuItem>
      ))}
      <ListSubheader>Cyclical</ListSubheader>
      {presets['Cyclical'].map(value => (
        <MenuItem
          key={value}
          value={value}
          sx={{ backgroundColor: 'transparent', height: theme => theme.spacing(4) }}
        >
          {value}
        </MenuItem>
      ))}
    </Select>
  )
}
