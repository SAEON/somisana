import { createTheme } from '@mui/material/styles'
import darkTheme from './_dark-theme'
import lightTheme from './_light-theme'

// For reference via the window object
window.theme = { light: lightTheme, dark: darkTheme }

export const light = createTheme(createTheme(lightTheme), {})

export const dark = createTheme(createTheme(darkTheme), {})
