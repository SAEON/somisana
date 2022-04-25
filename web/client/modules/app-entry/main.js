import { hydrateRoot } from 'react-dom/client'
import ConfigProvider from '../config/index.js'
import ThemeProvider from '@mui/material/styles/ThemeProvider'
import theme from '../../../theme/mui/index.js'
import CssBaseline from '@mui/material/CssBaseline'

const App = ({ children }) => (
  <CssBaseline>
    <ThemeProvider theme={theme}>
      <ConfigProvider>{children}</ConfigProvider>
    </ThemeProvider>
  </CssBaseline>
)

export default Page =>
  hydrateRoot(
    document.getElementById('root'),
    <App>
      <Page />
    </App>
  )
