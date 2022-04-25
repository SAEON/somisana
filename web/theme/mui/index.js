import createTheme from 'https://ga.jspm.io/npm:@mui/material@5.6.2/styles/createTheme.js'
import red from 'https://ga.jspm.io/npm:@mui/material@5.6.2/colors/red.js'

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
