import { hydrateRoot } from 'react-dom/client'
import ConfigProvider from '../config/index.js'
import Apollo from '../apollo/index.js'
import ThemeProvider from '@mui/material/styles/ThemeProvider'
import theme from '../../../theme/mui/index.js'
import CssBaseline from '@mui/material/CssBaseline'
import { CacheProvider as EmotionCacheProvider } from '@emotion/react'
import createEmotionCache from '../../../create-emotion-cache.js'
import { BrowserRouter } from 'react-router-dom'

const cache = createEmotionCache()

const App = ({ children }) => (
  <EmotionCacheProvider value={cache}>
    <ThemeProvider theme={theme}>
      <CssBaseline>
        <ConfigProvider>
          <Apollo>
            <BrowserRouter>{children}</BrowserRouter>
          </Apollo>
        </ConfigProvider>
      </CssBaseline>
    </ThemeProvider>
  </EmotionCacheProvider>
)

export default Page =>
  hydrateRoot(
    document.getElementById('root'),
    <App>
      <Page />
    </App>
  )
