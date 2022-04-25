import createTheme from '@mui/material/styles/createTheme'
import red from '@mui/material/colors/red'

const theme = createTheme()

export default createTheme(theme, {
  shape: {
    borderRadius: 2
  },
  palette: {
    mode: 'light',
    primary: {
      main: red[800]
    },
    secondary: {
      main: red[100]
    }
  },
  components: {
    MuiUseMediaQuery: {
      defaultProps: {
        noSsr: true
      }
    }
  },
  typography: {
    h1: {
      fontSize: '2.5rem'
    },
    h2: {
      fontSize: '2rem'
    },
    h5: {
      fontSize: '1.2rem'
    },
    h6: {
      fontSize: '1rem'
    }
  }
})
