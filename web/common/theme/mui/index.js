import createTheme from '@mui/material/styles/createTheme'
import blueGrey from '@mui/material/colors/blueGrey'

const systemFont = [
  '-apple-system',
  'BlinkMacSystemFont',
  '"Segoe UI"',
  'Roboto',
  '"Helvetica Neue"',
  'Arial',
  'sans-serif',
  '"Apple Color Emoji"',
  '"Segoe UI Emoji"',
  '"Segoe UI Symbol"',
]

const theme = createTheme({
  shape: {
    borderRadius: 2,
  },
  palette: {
    mode: 'dark',
    primary: {
      main: blueGrey[700],
    },
    secondary: {
      main: blueGrey[100],
    },
  },
  typography: {
    allVariants: {
      fontFamily: systemFont.join(','),
    },
  },
})

export default createTheme(theme, {})
