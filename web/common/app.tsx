import { CacheProvider as EmotionCacheProvider } from '@emotion/react'
import ThemeProvider from '@mui/material/styles/ThemeProvider'
import CssBaseline from '@mui/material/CssBaseline'
import theme from './theme/mui'
import ConfigProvider from '../client/modules/config'
import SiteSettingsProvider from '../client/modules/site-settings'
import createCache from '@emotion/cache'
import { ApolloProvider } from '@apollo/client'

export const createEmotionCache = () => createCache({ key: 'css' })

const App = ({ Router, apolloClient, children, emotionCache = createEmotionCache() }) => (
  <EmotionCacheProvider value={emotionCache}>
    <ThemeProvider theme={theme}>
      <CssBaseline>
        <ConfigProvider>
          <SiteSettingsProvider>
            <ApolloProvider client={apolloClient}>
              <Router>{children}</Router>
            </ApolloProvider>
          </SiteSettingsProvider>
        </ConfigProvider>
      </CssBaseline>
    </ThemeProvider>
  </EmotionCacheProvider>
)

export default App
