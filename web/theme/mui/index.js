import createTheme from '@mui/material/styles/createTheme'
import red from '@mui/material/colors/red'

const theme = createTheme({
  shape: {
    borderRadius: 2,
  },
  palette: {
    mode: 'light',
    primary: {
      main: red[800],
    },
    secondary: {
      main: red[100],
    },
  },
  typography: {
    allVariants: {
      fontFamily: [
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
      ].join(',')
    }
  }
})

export default createTheme(theme, {})
