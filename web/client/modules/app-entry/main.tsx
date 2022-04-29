import { hydrateRoot } from 'react-dom/client'
import ConfigProvider from '../config'
import Apollo from '../apollo'
import ThemeProvider from '@mui/material/styles/ThemeProvider'
import theme from '../../../theme/mui'
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
