import { CacheProvider as EmotionCacheProvider } from '@emotion/react'
import ThemeProvider from '@mui/material/styles/ThemeProvider'
import CssBaseline from '@mui/material/CssBaseline'
import theme from './theme/mui'
import ConfigProvider from '../client/modules/config'
import SiteSettingsProvider from '../client/modules/site-settings'
import I18nProvider from '../client/modules/i18n'
import createCache from '@emotion/cache'
import { ApolloProvider } from '@apollo/client'

export const createEmotionCache = () => createCache({ key: 'css' })

const App = ({
  Router,
  apolloClient,
  children,
  emotionCache = createEmotionCache(),
  cookie = undefined,
  acceptLanguage = 'en',
}) => {
  console.log('acceptLanguage', acceptLanguage)
  return (
    <EmotionCacheProvider value={emotionCache}>
      <ThemeProvider theme={theme}>
        <CssBaseline>
          <ConfigProvider>
            <SiteSettingsProvider acceptLanguage={acceptLanguage} cookie={cookie}>
              <I18nProvider>
                <ApolloProvider client={apolloClient}>
                  <Router>{children}</Router>
                </ApolloProvider>
              </I18nProvider>
            </SiteSettingsProvider>
          </ConfigProvider>
        </CssBaseline>
      </ThemeProvider>
    </EmotionCacheProvider>
  )
}

export default App
