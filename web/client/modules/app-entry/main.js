import { hydrateRoot } from 'react-dom/client'
import ConfigProvider from '../config/index.js'
import ThemeProvider from '@mui/material/styles/ThemeProvider'
import theme from '../../../theme/mui/index.js'
import CssBaseline from '@mui/material/CssBaseline'
import { CacheProvider } from '@emotion/react'
import createEmotionCache from '../../../create-emotion-cache.js'

const cache = createEmotionCache()

const App = ({ children }) => (
  <CacheProvider value={cache}>
    <ThemeProvider theme={theme}>
      <CssBaseline>
        <ConfigProvider>{children}</ConfigProvider>
      </CssBaseline>
    </ThemeProvider>
  </CacheProvider>
)

export default Page =>
  hydrateRoot(
    document.getElementById('root'),
    <App>
      <Page />
    </App>
  )
