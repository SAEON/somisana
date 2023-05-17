import { CacheProvider as EmotionCacheProvider } from '@emotion/react'
import CssBaseline from '@mui/material/CssBaseline'
import { light as lightTheme, dark as darkTheme } from './theme/mui'
import ConfigProvider from '../client/modules/config'
import SiteSettingsProvider from '../client/modules/site-settings'
import I18nProvider from '../client/modules/i18n'
import createCache from '@emotion/cache'
import { ApolloProvider } from '@apollo/client'
import ErrorBoundary from '../client/components/error-boundary'
import NativeExtensions from '../client/modules/native-extensions'
import { SnackbarProvider } from 'notistack'
import Theme from './theme'
import c from 'cookie'

const SETTINGS_COOKIE_KEY = 'SOMISANA_SITE_SETTINGS'

const LANGS = ['en']

const negotiator = language => {
  return LANGS[0]
}

export const createEmotionCache = () => createCache({ key: 'css' })

const App = ({
  Router,
  apolloClient,
  children,
  emotionCache = createEmotionCache(),
  cookie = undefined,
  acceptLanguage = negotiator(window.navigator.language),
}) => {
  /**
   * Load the cookie
   */
  const _cookie = c.parse(
    cookie || (typeof document === 'undefined' ? '' : document.cookie) || ''
  )?.[SETTINGS_COOKIE_KEY]

  const sessionSettings = JSON.parse(_cookie || '{}')

  return (
    <EmotionCacheProvider value={emotionCache}>
      <ConfigProvider>
        <SiteSettingsProvider
          acceptLanguage={acceptLanguage}
          cookieKey={SETTINGS_COOKIE_KEY}
          sessionSettings={sessionSettings}
        >
          <Theme themes={{ light: lightTheme, dark: darkTheme }}>
            <CssBaseline>
              <I18nProvider>
                <ApolloProvider client={apolloClient}>
                  <ErrorBoundary>
                    <NativeExtensions>
                      <SnackbarProvider>
                        <Router>{children}</Router>
                      </SnackbarProvider>
                    </NativeExtensions>
                  </ErrorBoundary>
                </ApolloProvider>
              </I18nProvider>
            </CssBaseline>
          </Theme>
        </SiteSettingsProvider>
      </ConfigProvider>
    </EmotionCacheProvider>
  )
}

export default App
